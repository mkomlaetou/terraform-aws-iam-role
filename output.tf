####################
# OUTPUT
####################

output "role_details" {
  description = "output role ID, ARN, Unique ID and Instance Profile Name"
  value = {
    id           = aws_iam_role.role.id
    arn          = aws_iam_role.role.arn
    unique_id    = aws_iam_role.role.unique_id
    profile_name = var.role_details.instance_profile == true ? aws_iam_instance_profile.ec2[0].name : "n/a"
  }
}