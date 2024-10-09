# Load variables in locals
locals {
  # Default values for variables
  provider = "aws"
  client   = "Bancolombia"
  project  = "blueprint-devsecops-ecs-ado"

  # Backend Configuration
  backend_profile       = "sh-tm-bco"
  backend_region        = "us-east-1"
  backend_bucket_name   = "blueprint-devsecops-cluster-prd-terraform-remote-tfstate"
  backend_key           = "terraform.tfstate"
  backend_dynamodb_lock = "blueprint-devsecops-cluster-prd-terraform-db-lock"
  backend_encrypt       = true
  # Format cloud provider/client/projectname
  project_folder = "${local.provider}/${local.client}/${local.project}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

variable "profile" {
  description = "Variable for credentials management."
  type        = map(map(string))
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "required_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}



provider "aws" {
  region  = var.profile[terraform.workspace]["region"]
  profile = var.profile[terraform.workspace]["profile"]

  default_tags {
    tags = var.required_tags
  }
}
EOF
}
