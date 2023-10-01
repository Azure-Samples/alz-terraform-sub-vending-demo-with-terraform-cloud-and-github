$owner = "github-organisation-name"
$repository = "github-repositry-name"
$access_token = "ghp_1234567890abcdefghijklmnopqrstuvwxyz"
$subscriptionData = @"
{
    "subscription_name": "sub-demo-001"
}
"@

./trigger_destroy.ps1 -access_token $access_token -owner $owner -repository $repository -subscriptionData $subscriptionData
