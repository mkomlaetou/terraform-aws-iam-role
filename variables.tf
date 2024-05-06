// Global

variable "additional_tags" {
  description = "additional tags"
  type        = map(string)
  default     = null
}

/**
 * Defines the properties of an IAM Role, including the role name, cross-account access, principals, custom STS policy, permission policy, managed policies, and whether to create an instance profile.
 *
 * @param role_name - The name of the IAM Role.
 * @param crossing_account_ids - A list of AWS account IDs that are allowed to assume the IAM Role.
 * @param principals - A list of AWS principals (e.g. IAM users, roles, services) that are allowed to assume the IAM Role.
 * @param custom_sts_policy_file_path - The file path to a custom STS policy that will be attached to the IAM Role.
 * @param permission_policy_file_path - A map of permission policy file paths that will be attached to the IAM Role.
 * @param managed_policies - A list of AWS managed policies that will be attached to the IAM Role.
 * @param instance_profile - Whether to create an instance profile for the IAM Role.
 */

// Role variable
variable "role_details" {
  description = "properties of the IAM Role"
  type = object({
    role_name                   = string
    crossing_account_ids        = optional(list(string), [])
    principals                  = optional(list(string), [])
    custom_sts_policy_file_path = optional(string, "")
    permission_policy_file_path = optional(map(string), { none = "/policies/none.json" })
    managed_policies            = optional(list(string), [])
    instance_profile            = optional(bool, false)
  })
}

