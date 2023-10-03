---
page_type: sample
languages:
- terraform
- hcl
- yaml
name: Azure Landing Zones Subscription Vending with Terraform, Terraform Cloud and GitHub
description: A sample showing an example of self-service subscription vending with GitHub and Terraform Cloud.
products:
- azure
- github
urlFragment: alz-terraform-sub-vending
---

# Azure Landing Zones Subscription Vending with Terraform, Terraform Cloud and GitHub

This example shows one approach to self-service subscription vending in Azure. It leverages the ALZ Terrafrom subscription vending module, Terraform Cloud and GitHub to demonstrate an end to end process of vending subscriptions for different use cases.

## Content

| File/folder | Description |
|-------------|-------------|
| `terraform-example-deploy` | Some Terraform with Azure Resources for the demo to deploy. |
| `terraform-oidc-config` | The Terraform to configure Azure and Azure DevOps ready for Managed Identity or OIDC authenticaton. |
| `.gitignore` | Define what to ignore at commit time. |
| `CHANGELOG.md` | List of changes to the sample. |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md` | This README file. |
| `LICENSE.md` | The license for the sample. |

## Features

This demo has the following concepts:

- A central GitHub repo and pipeline that vends subscriptions.
- A subscription vending process that creates a Terraform Cloud workspace and vends a subscription via the workspace.
- A vended subscription includes a number of other resources:
    - Resource groups
    - Permissions
    - User Assigned Managed Identity and Federated Credentials for Terraform Cloud
    - A user Terraform Cloud workspace
    - A repository for a persona template which includes variables, secrets, action and example code to deploy a VM

The process flow is:

1. Setup the config to vend your subscription
1. Trigger the vend GitHub action via repository_dispatch API call
1. Wait for the management workspace, subscription, user repository and user workspace to be created
1. Naviagate to the user repository and trigger the action to deploy the example VM workload into the newly vended subscription

## Getting Started

### Prerequisites

- HashiCorp Terraform CLI: [Download](https://www.terraform.io/downloads)
- Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- An Azure Tenant with Billing Account Access
- A GitHub Organization: [Free Organization](https://aex.dev.azure.com/signup/)
- A licensed Terraform Cloud organization: [Portal](https://app.terraform.io/)

### Installation

- Fork the repository. This is important as you need to be able to run the GitHub Actions in your organisation.
- Clone it locally.
- Follow the quickstart.

### Quickstart

There are a few manual steps to get this demo up and running. Please note that this demo is conceptual. You will note that we are using GitHub PAT tokens and Terraform Cloud user API tokens. If you want to use this example for a production scenario, you should use alternative authentication.

#### Setup a Service Principal for Subscription Vending

In order to use this demo, you need create a Service Principal and assign billing account permissions. You then need to generate a secret for it. We'll need the tenant id, client id and client secret for this service principal later on.

You will also need at least one pre-existing subscription in your tenant. We won't deploy or alter anything in that subscription, but due to a limitation of the `azurerm` provider, we need to proved a subsscription id. Take a not of the subscription id for later.

##### Create the Service Principal

The following command is over-permissive but works well for a demo, you will need to be a global admin and tick the "access management for Azure resources" box in Entra ID.

```bash
$ az ad sp create-for-rbac -n "terraform-sub-vending-demo" --role "Owner" --scopes "/"
```

##### Entra ID permissions for the Service Principal

The SPN needs the `User.ReadAll` permission. See the [AzureAD provider documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration#azure-active-directory-permissions).

#### Create a Management Group
For now need a management group other than whatever you default Management Group is to use this demo. If you already have one, then take a note of it's name and use that in place of `sub-vending-demo` in future steps.

1. Login to the Azure Portal
1. Search for `Management Groups`
1. Click `+ Create`
1. Enter `sub-vending-demo` in both the `Management group ID` and `Management group display name` fields
1. Click `Submit`

#### Generate a GitHub PAT Token

1. Navigate to [github.com](https://github.com).
1. Click on your user icon in the top right and select `Settings`.
1. Scroll down and click on `Developer Settings` in the left navigation.
1. Click `Personal access tokens` in the left navigation and select `Tokens (classic)`.
1. Click `Generate new token` at the top and select `Generate new token (classic)`.
1. Enter `Azure Landing Zone Terraform Accelerator` in the `Note` field.
1. Alter the `Expiration` drop down and select `Custom`.
1. Choose tommorrows date in the date picker.
1. Check the following scopes:
    1. `repo`
    1. `delete_repo`
1. Click `Generate token`.
1. Copy the token and save it somewhere safe.
1. If you are a Microsoft Employee, you must grant your token SSO access to any one Microsoft org you are a member of.
1. Select an organization and click `Authorize`, then follow the prompts to allow SSO.

#### Generate a Terraform Cloud API Token

1. Login to Terraform Cloud
1. Click the user image in the top left and select `User Settings`
1. Navigate to `Tokens` and click `Create an API token`
1. Type `Subscription Vending Demo` into the `Description` field and click `Generate token`
1. Copy the generated token and save it somewhere secure for the next parts of thr setup

#### Setup Terraform Cloud

1. Login to your Terraform Cloud organisation.
1. Ensure you have `Project and workspaces` selected.
1. Click `New` and select `Project`.
1. Enter `sub-vend-demo-mgmt` and click `Create`.
1. Click `New` and select `Project`.
1. Enter `sub-vend-demo-user` and click `Create`.
1. Navigate to `Settings` and select `Variable sets`.
1. Click `Create variable set`.
1. Enter `sub-vend-demo-mgmt` into the `Name`.
1. Ensure `Apply to specific projects and workspaces` is selected.
1. Click `Select projects` and select `sub-vend-demo-mgmt`.
1. Scroll down and repeat the process of clicking `Add variable`, selecting `Environment variable`, filling our the `Key` and `Value` and clicking `Add variable` as follows:
    1. Check the `Sensitive` box for `TFE_TOKEN`: The Terraform Cloud API Token you created earlier
    1. Check the `Sensitive` box for `GITHUB_TOKEN`: The GitHub PAT you created earlier
    1. `ARM_TENANT_ID`: Your Azure Tenant Id
    1. `ARM_SUBSCRIPTION_ID`: Your Azure Subscription Id (remember this won't be used, but is require by the Terraform provider)
    1. `ARM_CLIENT_ID`: The client ID of the service principal that was setup for subscription vending
    1. Check the `Sensitive` box for `ARM_CLIENT_SECRET`: The client secret of the service principal that was setup for subscription vending
1. repeat the process of clicking `Add variable`, selecting `Terraform variable`, filling our the `Key` and `Value` and clicking `Add variable` as follows:
    1. `terraform_cloud_organisation`: This is the name of you Terraform Cloud Organisation.
    1. `terraform_cloud_user_project`: This is `sub-vend-demo-user`.
    1. `billing_account_type`: Choose between `ea`, `mca` or `mpa` depending on your account type
    1. `billing_account_name`: The name of your billing account. This is the `Billing account ID` of your billing account, such as `7690848` for EA or `e879cf0f-2b4d-5431-109a-f72fc9868693:024cabf4-7321-4cf9-be59-df0c77ca51de_2019-05-31` for MCA or MPA.
    1. If you are using EA Billing then enter these variables:
        1. `billing_enrollment_account_name`: This is the billing enrollment. This is the `Account ID` of your billing enrollment, such as `340388`.
    1. If you are using MCA Billing, then enter these variables:
        1. `billing_profile_name`: This is the billing profile id, such as `PE2Q-NOIT-BG7-TGB`.
        1. `billing_invoice_section_name`: This is the billing invoice section id, such as `MTT4-OBS7-PJA-TGB`.
    1. If you are using MPA Billing, then enter these variables:
        1. `billing_customer_name`: This is the billing customer id, such as `2281f543-7321-4cf9-1e23-edb4Oc31a31c`.
1. Ok, we are all done with the Terraform Cloud configuration.

#### Fork the Repo and Setup the GitHub Variables

1. Create a fork of this repository in your own organisation.
1. Open the repository, click `Settings`, then `Secrets and variable` and click `Actions`.
1. Ensure the `Secrets` tab is select, then click `New repository secret`.
1. Enter `TERRAFORM_CLOUD_TOKEN` into the `Name` and paste your Terraform Cloud API Token into the `Secret`, then click `Add secret`.
1. Now select the `Variable` tab. 
1. We are going to add the following variables by clicking `New repository variable` an filling out the `Name` and `Value` fields, then clicking `Add variable`:
    1. `TERRAFORM_CLOUD_URL`: This is `app.terraform.io`, unless you are using Terraform Enterprise, in which case enter the the url of your instance.
    1. `TERRAFORM_CLOUD_ORGANISATION`: This is the name of you Terraform Cloud Organisation.
    1. `TERRAFORM_CLOUD_PROJECT`: This is `sub-vend-demo-mgmt`.
1. Click `Actions` in the top menu.
1. Click `I understand my workflows, go ahead and enable them`.
1. Ok, we are all done with the GitHub configuration.

#### Setup the demo

1. Open Visual Studio Code and open the folder of your forked repository.
1. Copy the `examples/trigger_vend_example.ps1` and name the file `examples/trigger_vend_demo.ps1`.
1. Open the `trigger_vend_demo.ps1` and edit the variable values as follows:
    1. `$owner`: This is the GitHub organisation that you forked this repository into
    1. `$repository`: This is the name of your forked repository
    1. `$access_token`: This is the GitHub PAT you created earlier
    1. `$subscriptionData`: This is the payload for our example. Edit the following values as follow:
        1. `subscription_name`: You only need to change this if it clashes with an existing subscription you have.
        1. `location`: Change this to your desired Azure region
        1. `subscription_offer`: Choose `DevTest` or `Production` depending on what is available for your billing account
        1. `subscription_description`: Only change this if you changed the `subscription_name`
        1. `subscription_management_group`: This should be left as `sub-vending-demo` as per the management group you creatd earlier
        1. `resource_groups`: Only change these if you wish to update the locations.
        1. `subscription_owners`: This must be updated to a valid SPN in your Entra ID directory. For example `[ "first.last@org.com" ]`. If you don't update this you won't get access to the vended subscription and the demo will fail.
        1. `persona_template_organisation`: Don't change this
        1. `persona_template_repository`: Don't change this
        1. `repository_organisation`: Set this to the GitHub organisation you wish your user repository to be created in.
1. Save the file.
1. Copy the `examples/trigger_destroy_example.ps1` and name the file `examples/trigger_destroy_demo.ps1`.
1. Open the `trigger_destroy_demo.ps1` and edit the variable values as follows:
    1. `$owner`: This is the GitHub organisation that you forked this repository into
    1. `$repository`: This is the name of your forked repository
    1. `$access_token`: This is the GitHub PAT you created earlier
    1. `$subscriptionData`: This is the payload for our example. Edit the following values as follow:
        1. `subscription_name`: You only need to change this if you changed it in the vend file
1. Save the file
1. Ok, we are all done with the setup.

#### Run the demo

1. Open a terminal in Visual Studio Code.
1. Navigate to the the `examples` folder with `cd examples`.
1. Run `./trigger_vend_demo.ps1`.
1. Open your GitHub forked repository in the browser.
1. Navigate to `Actions` in the top menu.
1. Click on the running action and watch what it is doing.
1. Also navigate to Terrafrom Cloud and watch the workspaces being created and run.
1. When all the runs are finished, you can navigate to the Azure portal and take a look at the subscription and resources that have been created.

#### Clean up

1. Open a terminal in Visual Studio Code.
1. Navigate to the the `examples` folder with `cd examples`.
1. Run `./trigger_destroy_demo.ps1`.
1. Open your GitHub forked repository in the browser.
1. Navigate to `Actions` in the top menu.
1. Click on the running action and watch what it is doing.
1. Also navigate to Terrafrom Cloud and watch the workspaces run and deleted.
1. When all the runs are finished, you can navigate to the Azure portal and take a look at the subscription to see it has been cleaned to.
