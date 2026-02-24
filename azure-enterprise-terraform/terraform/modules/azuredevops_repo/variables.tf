variable "enable" {
  type    = bool
  default = false
}

variable "project_name" {
  type    = string
  default = null
}

variable "repository_name" {
  type    = string
  default = null
}

variable "branch_name" {
  type    = string
  default = "main"
}

# Optional basic policy (build validation requires pipeline id; left as placeholder)
variable "enable_min_reviewers_policy" {
  type    = bool
  default = false
}
variable "min_reviewer_count" {
  type    = number
  default = 1
}
