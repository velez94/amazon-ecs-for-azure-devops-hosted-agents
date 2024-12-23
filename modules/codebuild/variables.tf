#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
}

variable "build_projects" {
  description = "List of Names of the CodeBuild projects to be created"
  type        = list(string)
}

variable "builder_compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
}

variable "builder_image" {
  description = "Docker image to use for the build project"
  type        = string
}

variable "builder_type" {
  description = "Type of build environment to use for related builds"
  type        = string
}

variable "builder_image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build."
  type        = string
}

variable "build_project_source" {
  description = "Information about the build output artifact location"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "build_spec" {
  default = "BuildSpec template"
  type    = string
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR Repository Name"
}

variable "container_image_tag" {
  type        = string
  description = "ECR Container Image Tag"
}

variable "code_artifacts_repo_name" {
  type        = string
  description = "Code Artifacts Repository Name"
}
variable "code_artifacts_domain_name" {
  type        = string
  description = "Code Artifacts Domain Name"
}

variable "code_artifacts_owner" {
  type        = string
  description = "Code Artifacts Owner"
}


variable "code_artifacts_region" {
  type        = string
  description = "Code artifacts region"
}