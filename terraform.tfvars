project_name       = "ado-ecs-runner"
environment        = "dev"
source_repo_name   = "ado-ecs-repo"
source_repo_branch = "main"
create_new_repo    = true
create_new_role    = true

stage_input = [
  { name             = "build-image", category = "Test", owner = "AWS", provider = "CodeBuild",
    input_artifacts  = "SourceOutput", output_artifacts = "ValidateOutput-terraform"
  }
]
build_projects = ["build-image"]

# ECS   
container_env_vars = [
  { name = "LOG_LEVEL", value = "DEBUG" },
  { name = "PORT", value = "80" },
  { name = "AZP_URL", value = "https://dev.azure.com/sophosproyectos/" }, // Replace with your ADO Org URL
  { name = "AZP_POOL", value = "ecs-cluster-devsecops" }, // Replace with your ADO Agent Pool name
]
container_port         = 80
container_host_port    = 80
ecs_service_count      = "2"
container_image_tag    = "ado-ecs"
ecr_repo_name          = "ado-ecs-ecr"
ecs_cluster_name       = "ado-ecs"
ecs_container_def_name = "ado-ecs-tf"
ecs_service_name       = "ado-ecs-svc"
ecs_ado_patsecret_name = "ecs-ado-pat-secret"

lambda_memory_size = "128"
lambda_timeout = "90"

#todo parametrize for load from environments
subnet_ids = "subnet-0652671938450949a" // Replace with subnet-id from your account
security_groups = "sg-06c6956b2fd62e33b"     // Replace with security-group-id from your account

ado_org = "sophosproyectos"  // Replace with your ADO Org ID

#Todo parametrize ado org variable
# code artifacts variables values
code_artifacts_domain_name = "devsecops-accelerators" // Replace with your ADO Org ID
code_artifacts_repo_name = "DevSecOpsAccelerators"
code_artifacts_owner     = "225311078840"
code_artifacts_region    = "us-east-2"


########################################################################################################################
# Remote state
########################################################################################################################

# S3 bucket for remote state
remote_state_bucket_arn = "arn:aws:s3:::715841372027-us-east-1-terraform-state"
remote_state_table_arn     = "arn:aws:dynamodb:us-east-1:715841372027:table/terraform-state-locks"

########################################################################################################################
# Environments account values
########################################################################################################################
default_workload_account = "715841372027"
terraform_project_name = "tm-bco"