param(
    [string]$terraformCloudOrganisation,
    [string]$terraformCloudProject,
    [string]$terraformCloudUrl,
    [string]$terraformCloudAccessToken,
    [string]$subscriptionData
)

Write-Host "terraformCloudOrganisation: $terraformCloudOrganisation"
Write-Host "terraformCloudProject: $terraformCloudProject"
Write-Host "terraformCloudUrl: $terraformCloudUrl"
Write-Host "terraformCloudAccessToken: $terraformCloudAccessToken"
Write-Host "subscriptionData: $subscriptionData"

$subscriptionData | Out-File -FilePath ./terraform.tfvars.json

tar -cvzf config.tar.gz ./*.tf ./terraform.tfvars.json ./modules

$subscriptionVariables = ConvertFrom-Json $subscriptionData

$workspaceName = $subscriptionVariables.subscription_name

$headers=@{
  "Authorization" = "Bearer $terraformCloudAccessToken"
}

$terraformCloudUrlPrefix = "https://$($terraformCloudUrl)/api/v2"

Write-Host "Checking if workspace $workspaceName exists."
$uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganisation)/workspaces/$($workspaceName)"
$workspace = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

if($statusCode -eq "404")
{
    Write-Host "Workspace $workspaceName does not exist. Creating it now."

    $uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganisation)/projects?filter[names]=$($terraformCloudProject)"
    $project = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $projectId = $project.data.id

    $uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganisation)/workspaces"
    $body = @{
        "data" = @{
            "type" = "workspaces";
            "attributes" = @{
                "name" = $workspaceName;
                "auto-apply" = $true;
                "file-triggers-enabled" = $false;
                "operations" = @{
                    "destroy" = $true;
                }
            }
            "relationships" = @{
                "project" = @{
                    "data" = @{
                        "type" = "projects"
                        "id" = $projectId
                    }
                }
            }
        }
    }
    $bodyJson = ConvertTo-Json $body -Depth 10
    $workspace = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType "application/vnd.api+json" -Body $bodyJson
    $workspaceId = $workspace.data.id
}
else
{
    Write-Host "Workspace $workspaceName already exists."
    $workspaceId = $workspace.data.id
}

Write-Host "Creating workspace configuration version for $workspaceName ($workspaceId)."
$uri = "$terraformCloudUrlPrefix/workspaces/$($workspaceId)/configuration-versions"
$body = @{
    "data" = @{
        "type" = "configuration-versions";
        "attributes" = @{
            "auto-queue-runs" = $false
        }
    }
}
$bodyJson = ConvertTo-Json $body -Depth 10
$configurationVersion = Invoke-RestMethod -Uri $uri  -Headers $headers -Method Post -ContentType "application/vnd.api+json" -Body $bodyJson
$uploadUrl = $configurationVersion.data.attributes."upload-url"
$configurationVersionId = $configurationVersion.data.id

Invoke-RestMethod -Uri $uploadUrl -Headers $headers -Method Put -ContentType "application/octet-stream" -InFile ./config.tar.gz

Write-Host "Queueing run for $workspaceName ($workspaceId)."
$uri = "$terraformCloudUrlPrefix/runs"
$body = @{
    "data" = @{
        "attributes" = @{
            "message" = "Triggered From Subscription Vending GitHub Action"
        }
        "type" = "runs"
        "relationships" = @{
            "workspace" = @{
                "data" = @{
                    "type" = "workspaces"
                    "id" = $workspaceId
                }
            }
            "configuration-version" = @{
                "data" = @{
                    "type" = "configuration-versions"
                    "id" = $configurationVersionId
                }
            }
        }
    }
}
$bodyJson = ConvertTo-Json $body -Depth 10
$runResult = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType "application/vnd.api+json" -Body $bodyJson

$runId = $runResult.data.id
$runStatus = $runResult.data.attributes.status

$finalStatus = @(
    "planned_and_finished",
    "applied",
    "errored",
    "discarded",
    "canceled",
    "force_canceled"
)

while(!($finalStatus.Contains($runStatus)))
{
    Write-Host "Waiting for run to complete. Current status: $runStatus"
    Start-Sleep -Seconds 5
    $uri = "$terraformCloudUrlPrefix/runs/$runId"
    $runResult = Invoke-RestMethod -Method "GET" -Uri $uri -Headers $headers
    $runStatus = $runResult.data.attributes.status
}

$outputs = @()

if($runStatus -eq "applied" -or $runStatus -eq "planned_and_finished")
{
    Write-Host "Run completed and applied successfully."
    $uri = "$terraformCloudUrlPrefix/workspaces/$workspaceId/current-state-version"
    $stateVersion = Invoke-RestMethod -Method "GET" -Uri $uri -Headers $headers

    $stateVersionId = $stateVersion.data.id

    $uri = "$terraformCloudUrlPrefix/state-versions/$stateVersionId/outputs"
    $outputResult = Invoke-RestMethod -Method "GET" -Uri $uri -Headers $headers

    foreach($output in $outputResult.data)
    {
        $outputName = $output.attributes.name
        $outputValue = $output.attributes.value
        $outputType = $output.attributes.type
        $outputObject = @{
            "name" = $outputName
            "value" = $outputValue
            "type" = $outputType
        }
        $outputs += $outputObject
    }
}

$result = @{
    "workspaceId" = $workspaceId
    "runId" = $runId
    "runStatus" = $runStatus
    "outputs" = $outputs
}

return $result | ConvertTo-Json -Depth 10