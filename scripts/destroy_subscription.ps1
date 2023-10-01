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

$subscriptionVariables = ConvertFrom-Json $subscriptionData

$vendWorkspaceName = $subscriptionVariables.subscription_name
$userWorkspaceName = "user-$vendWorkspaceName"

$workspaces = @(
    $userWorkspaceName,
    $vendWorkspaceName
)

$headers=@{
  "Authorization" = "Bearer $terraformCloudAccessToken"
}

$terraformCloudUrlPrefix = "https://$($terraformCloudUrl)/api/v2"

Write-Host "Run destroy plan on workspaces."

foreach($workspace in $workspaces)
{
    Write-Host "Getting workspace ID for $workspace"

    $uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganisation)/workspaces/$($workspace)"
    $workspace = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

    if($statusCode -ne "404")
    {
        Write-Host "Workspace $workspaceName exists. Destroying it now."
        $workspaceId = $workspace.data.id

        Write-Host "Queueing run for $workspaceName ($workspaceId)."
        $uri = "$terraformCloudUrlPrefix/runs"
        $body = @{
            "data" = @{
                "attributes" = @{
                    "message" = "Destroy triggered From Subscription Vending GitHub Action"
                    "is-destroy" = $true
                    "auto-apply" = $true
                }
                "type" = "runs"
                "relationships" = @{
                    "workspace" = @{
                        "data" = @{
                            "type" = "workspaces"
                            "id" = $workspaceId
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

        if($runStatus -eq "applied" -or $runStatus -eq "planned_and_finished")
        {
            Write-Host "Successfully destroyed $workspace"
        }
        else 
        {
            Write-Error "Failed to destroy $workspace"
            exit 1
        }
    }
    else
    {
        Write-Host "Workspace $workspaceName does not exists."
    }
}


Write-Host "Deleting vending workspace $vendWorkspaceName"

$uri = "$terraformCloudUrlPrefix/organizations/$($terraformCloudOrganisation)/workspaces/$($vendWorkspaceName)"
Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete -ContentType "application/vnd.api+json"