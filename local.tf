locals {
  default_tags = {
    IACTool = "terraform"
    # service_name = var.service_name
  }

  tags = merge(local.default_tags, var.additional_tags)
}

// Create Manages policies arn list

locals {
  policies             = [for k in data.aws_iam_policy.policy : k.arn]
  principals           = [for k in var.role_details.principals : "${k}.amazonaws.com"]
  crossing_account_ids = [for k in var.role_details.crossing_account_ids : "arn:aws:iam::${k}:root"]
}
