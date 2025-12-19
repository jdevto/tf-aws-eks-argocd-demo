variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "9.1.9"
}

variable "repo_url" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "target_revision" {
  type    = string
  default = "main"
}

variable "app_path" {
  type = string
}

variable "app_name" {
  type    = string
  default = "demo-web"
}
