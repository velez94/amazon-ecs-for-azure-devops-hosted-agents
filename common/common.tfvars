# Default values for deployment credentials
# Access profile in your IDE env or pipeline the IAM user to use for deployment."
profile = {
  default = {
    profile = "sh-tm-bco"
    region  = "us-east-1"
  }
  "dev" = {
    profile = "sh-tm-bco"
    region  = "us-east-1"
  }
}

# Project Variable
project = "blueprint-devsecops-ecs-ado"

# Project default tags
required_tags = {
  Project   = "blueprint-devsecops-ecs-ado"
  Owner     = "DevSecOps"
  ManagedBy = "Terraform-Terragrunt"
}
