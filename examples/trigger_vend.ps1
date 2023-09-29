param(
    [string]$access_token,
    [string]$owner,
    [string]$repository,
    [string]$subscriptionData
)

Write-Host "subscriptionData: $subscriptionData"

$headers=@{
  "Authorization" = "Bearer $access_token"
  "X-GitHub-Api-Version" = "2022-11-28"
}

$subscriptionVariables = ConvertFrom-Json $subscriptionData

$url = "https://api.github.com/repos/$owner/$repository/dispatches"
$body=@{
  "event_type" = "vend_subscription"
  "client_payload" = @{
    "subscriptionData" = $subscriptionVariables
  }
}
$bodyJson = ConvertTo-Json $body -Depth 10

$result = Invoke-RestMethod -Method "POST" -Uri $url -Body $bodyJson -Headers $headers -ContentType "application/vnd.github+json"
