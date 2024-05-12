
// generate cross account sts policy document
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


// generate service sts policy document
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


// retrive arn of managed and custom policies
data "aws_iam_policy" "policy" {
  for_each = var.role_details.managed_policies == [] ? null : toset(var.role_details.managed_policies)
  name     = each.key
}



#####################
# CREATE ROLE
####################

// create an IAM role with Assuned Policy and inline policies
resource "aws_iam_role" "role" {
  description        = "create an IAM role with inline / managed policies and sts policy"
  name               = var.role_details.role_name
  assume_role_policy = local.crossing_account_ids != [] ? data.aws_iam_policy_document.cross_account_policy[0].json : local.principals != [] ? data.aws_iam_policy_document.service_account_policy[0].json : file("${path.cwd}${var.role_details.custom_sts_policy_file_path}")

  dynamic "inline_policy" {
    for_each = var.role_details.permission_policy_file_path
    content {
      name   = inline_policy.key
      policy = inline_policy.key == "none" ? file("${path.module}${inline_policy.value}") : file("${path.cwd}${inline_policy.value}")
    }
  }

  tags = merge(local.tags, tomap({ "Name" : var.role_details.role_name }))

}

// attach a list of policies to role (managed or custom)
resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(local.policies)
  role       = aws_iam_role.role.id
  policy_arn = each.value

}

// Creates an IAM instance profile with the same name as the IAM role, and associates the IAM role with the instance profile.
resource "aws_iam_instance_profile" "ec2" {
  count = var.role_details.instance_profile ? 1 : 0
  name  = var.role_details.role_name
  role  = aws_iam_role.role.name
}


