## USAGE:

This module allows you to create an AWS IAM Role with the following policies
  * an AssumeRole policy
  * one or many inline policies
  * attached custom and managed policies.

An AssumeRole policy is configured using only one the following three parameters:
  * crossing_account_ids: A list of AWS account that can assume the role.
  * principals: A list of AWS services that can assume the role. E.g ["ec2"]
  * custom_sts_policy_file_path: Path to a JSON policy file that defines the custom AssumeRole policy.
Order of precedence: crossing_account_ids > principals > custom_sts_policy_file_path

You add premission to the role by defining either or both of the following parameters: 
* permission_policy_file_path: multiple inline policies defined in a JSON file
* managed_policies: list of AWS or customer managed policies


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | additional tags | `map(string)` | `{}` | no |
| <a name="input_role_details"></a> [role\_details](#input\_role\_details) | properties of the IAM Role | <pre>object({<br>    role_name                   = string<br>    crossing_account_ids        = optional(list(string), [])<br>    principals                  = optional(list(string), [])<br>    custom_sts_policy_file_path = optional(string, "")<br>    permission_policy_file_path = optional(map(string), { none = "/policies/none.json" })<br>    managed_policies            = optional(list(string), [])<br>    instance_profile            = optional(bool, false)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_details"></a> [role\_details](#output\_role\_details) | output role ID, ARN, Unique ID and Instance Profile Name |




## SAMPLE CODE

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}


module "xyz_role" {
  source = "mkomlaetou/iam-role/aws"

  role_details    = var.xyz_role
  additional_tags = var.additional_tags
}



output "xyz_role_details" {
  value = module.xyz_role.role_details
}


// ROLE VARIABLE
variable "xyz_role" {
  default = {
    role_name = "xyz_ec2-s3_role"
    #crossing_account_ids        = ["000000000000", "1111111111111"]
    principals = ["ec2", "s3", "autoscaling"]
    #custom_sts_policy_file_path = "/policies/login_acc_general_sts_trust.json"
    permission_policy_file_path = {
      additional_p1 = "/policies/s3.json"
      additional_s2 = "/policies/ec2.json"
    }
    # "managed_policies" = ["AmazonS3ReadOnlyAccess", "AmazonEC2ReadOnlyAccess"]
    instance_profile = true
  }
}

// TAG VARIABLE
variable "additional_tags" {
  default = {
    created_by      = "mkomlaetou"
    created_on      = "2023-04-30"
    last_maintainer = "mkomlaetou"
    environment     = "dev"
  }
}

```