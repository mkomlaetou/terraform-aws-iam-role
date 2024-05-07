
/**
 * Defines two IAM policy documents:
 * - `cross_account_policy`: Allows users from other AWS accounts to assume the role, with the condition that multi-factor authentication is present.
 * - `service_account_policy`: Allows AWS services to assume the role.
 * Also defines a data source to retrieve the details of managed IAM policies that will be attached to the role.
 */

data "aws_iam_policy_document" "cross_account_policy" {
  count = var.role_details.crossing_account_ids != [] ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.crossing_account_ids
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true"
      ]
    }
  }
}

data "aws_iam_policy_document" "service_account_policy" {
  count = var.role_details.principals != [] ? 1 : 0
  statement {
    # sid     = ""
    # effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = local.principals
    }
  }
}


data "aws_iam_policy" "policy" {
  for_each = var.role_details.managed_policies == [] ? null : toset(var.role_details.managed_policies)
  name     = each.key
}



#####################
# CREATE ROLE
####################
/*
This resource creates an IAM role with the following configuration:
- Description: "create an IAM role with inline / managed policies and sts policy"
- Name: var.role_details.role_name
- Assume role policy: Either data.aws_iam_policy_document.cross_account_policy[0].json, data.aws_iam_policy_document.service_account_policy[0].json, or the contents of the file specified by var.role_details.custom_sts_policy_file_path
- Managed policy ARNs: Either the list of policies specified by var.role_details.managed_policies, or null if the list is empty
- Inline policies: One or more inline policies, where the policy document is read from the file specified by var.role_details.permission_policy_file_path
- Tags: A merged map of local.tags and a "Name" tag with the value of var.role_details.role_name
*/

resource "aws_iam_role" "role" {
  description        = "create an IAM role with inline / managed policies and sts policy"
  name               = var.role_details.role_name
  assume_role_policy = local.crossing_account_ids != [] ? data.aws_iam_policy_document.cross_account_policy[0].json : local.principals != [] ? data.aws_iam_policy_document.service_account_policy[0].json : file("${path.cwd}${var.role_details.custom_sts_policy_file_path}")

  #managed_policy_arns = var.role_details.managed_policies != [] ? local.policies : null
  dynamic "inline_policy" {
    for_each = var.role_details.permission_policy_file_path
    content {
      name   = inline_policy.key
      policy = file("${path.cwd}${inline_policy.value}")
    }
  }

  tags = merge(local.tags, tomap({ "Name" : var.role_details.role_name }))

}

/**
 * Creates an IAM instance profile with the same name as the IAM role, and associates the IAM role with the instance profile.
 * This resource is only created if the `instance_profile` flag in the `role_details` input variable is set to `true`.
 * The instance profile allows EC2 instances to assume the IAM role, which grants the instances the permissions defined in the role's policies.
 */

resource "aws_iam_instance_profile" "ec2" {
  count = var.role_details.instance_profile ? 1 : 0
  name  = var.role_details.role_name
  role  = aws_iam_role.role.name
}


resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(local.policies)
  role = aws_iam_role.role.id
  policy_arn = each.value

}