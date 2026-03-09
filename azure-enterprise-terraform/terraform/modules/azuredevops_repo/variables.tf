variable "enable" {
  type    = bool
  default = false
}

variable "create_project" {
  type    = bool
  default = false
}

variable "project_name" {
  type = string
}

variable "project_visibility" {
  type    = string
  default = "private"
}

variable "repository_name" {
  type = string
}

variable "default_branch" {
  type    = string
  default = "refs/heads/main"
}

variable "enable_min_reviewers_policy" {
  type    = bool
  default = true
}

variable "min_reviewer_count" {
  type    = number
  default = 2
}
