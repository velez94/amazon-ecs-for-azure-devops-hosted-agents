output "codecommit_url_http" {
  value       = module.codecommit_ado_agent_repo.clone_url_http
  description = "HTTP URL for CodeCommit Repo"
}

output "clone_url_http_grc" {
  value       = module.codecommit_ado_agent_repo.clone_url_http_grc
  description = "HTTP (GRC) URL for CodeCommit Repo"
}

output "ecs_ado_api_invoke_url" {
  value       = module.ecs_ado_api.api_invoke_url
  description = "URL to invoke ADO hosted agents dynamically via ECS Tasks"
}

output "ecs_ado_pat_secret_arn" {
  value       = aws_secretsmanager_secret.ecs_ado_pat.arn
  description = "Secret ARN to update with ADO PAT to setup agents"
}
output "remote_state_role_arn" {
  value = module.iam_backend_role_terraform
  description = "Remote role backend arn"
}

output "terraform_read_role_arn" {
  value = module.iam_deployment_read_role_terraform
  description = "Role for read operations"
}
output "terraform_write_role_arn" {
  value = module.iam_deployment_write_role_terraform
  description = "Role for read operations"
}