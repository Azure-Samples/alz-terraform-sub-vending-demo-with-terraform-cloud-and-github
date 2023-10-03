$owner = "github-organisation-name"
$repository = "github-repositry-name"
$access_token = "ghp_1234567890abcdefghijklmnopqrstuvwxyz"
$subscriptionData = @"
{
    "subscription_name": "sub-demo-001",
    "location": "uksouth",
    "subscription_offer": "DevTest",
    "subscription_description": "Demo Subscription 001",
    "subscription_management_group": "sub-vending-demo",
    "resource_groups": {
        "rg-demo-001": {
            "name": "rg-demo-001",
            "location": "uksouth",
            "primary": true
        },
        "rg-demo-002": {
            "name": "rg-demo-002",
            "location": "uksouth",
            "primary": false
        }
    },
    "subscription_owners": [
        "abc@def.com",
        "ghi@jkl.com"
    ],
    "persona_template_organisation": "azure-samples",
    "persona_template_repository": "alz-terraform-sub-vending-demo-with-terraform-cloud-and-github-persona-template-01",
    "repository_organisation": "github-organisation-name"
}
"@

./trigger_vend.ps1 -access_token $access_token -owner $owner -repository $repository -subscriptionData $subscriptionData
