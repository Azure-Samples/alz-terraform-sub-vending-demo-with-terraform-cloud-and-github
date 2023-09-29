$owner = "github-organisation-name"
$repository = "github-repositry-name"
$access_token = "ghp_1234567890abcdefghijklmnopqrstuvwxyz"
$subscriptionData = @"
{
    "subscription_name": "sub-demo-001",
    "location": "uksouth",
    "subscription_offer": "DevTest",
    "subscription_description": "Demo Subscription 001",
    "subscription_management_group": "management-group-name",
    "resource_groups": [
        "rg-demo-001",
        "rg-demo-002"
    ],
    "subscription_owners": [
        "abc@def.com",
        "ghi@jkl.com"
    ],
    "persona_template_organisation": "github-organisation-name",
    "persona_template_repository": "github-repository-name",
    "repository_organisation": "github-organisation-name",
}
"@

./trigger_vend.ps1 -access_token $access_token -owner $owner -repository $repository -subscriptionData $subscriptionData
