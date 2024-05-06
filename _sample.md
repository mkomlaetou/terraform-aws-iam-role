
## USAGE:

This module allows you to create an AWS IAM Role with an  AssumeRole policy,  customer managed inline policies and aws managed policies.
  * for cross account AssumeRole, simply assign the remote account id to the variable attribute "access_aws_acc".
  * for aws service AssumeRole or custom AssumeRole provide a json policy file to "sts_policy_file_path"
  * Role resource permission can be defined defined either using a customer json policy assigned to "permission_policy_file_path".
    * You can also assigned an AWS or Customer managed policy to "managed_policies" variable attribute

See _README.md file for other details
 
#---------------------------------------------------------------------
# SAMPLE CODE
#---------------------------------------------------------------------
```
module "xyz_role" {
  source = "../../modules/iam_assume_role"
  providers = {
    aws = aws.aws-dev
  }
  role_details  = var.xyz_role
  billing_group = var.billing_group
  service_name  = var.service_name
}
```

```
variable "xyz_role" {
  default = {
    "role_name" = "xyz_role"
    "access_aws_acc"              = "000000000000"
    "permission_policy_file_path" = "/policies/sqs_readonly.json"
    "sts_policy_file_path"        = "/policies/app_sync_trust.json"
    "managed_policies"            = ["AmazonS3ReadOnlyAccess", "AmazonEC2ReadOnlyAccess"]
  }
}
```