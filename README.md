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

TBC

## Getting Started

### Prerequisites

- HashiCorp Terraform CLI: [Download](https://www.terraform.io/downloads)
- Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- An Azure Tenant with Billing Account Access
- A GitHub Organization: [Free Organization](https://aex.dev.azure.com/signup/)

### Installation

- Fork the repository. This is important as you need to be able to run the GitHub Actions in your organisation.
- Clone it locally.
- Follow the quickstart.

### Quickstart

There are a few manual steps to get this demo up and running:

#### Fork and Setup Variables

1. 

