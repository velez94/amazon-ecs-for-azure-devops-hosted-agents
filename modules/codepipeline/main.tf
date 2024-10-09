#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.


resource "aws_iam_role" "event_role" {
  name = "EventRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eb_pipeline_execution" {
  name = "eb-pipeline-execution"
  role = aws_iam_role.event_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "codepipeline:StartPipelineExecution"
        Resource = "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_codepipeline.terraform_pipeline.name}"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_rule" "codecommit_event_rule" {
  name = "CodeCommitEventRule"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = ["arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.source_repo_name}"]
    detail = {
      event = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = [var.source_repo_branch]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline_target" {
  rule      = aws_cloudwatch_event_rule.codecommit_event_rule.name
  target_id = "codepipeline-AppPipeline"
  arn       = "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_codepipeline.terraform_pipeline.name}"
  role_arn  = aws_iam_role.event_role.arn
}




resource "aws_codepipeline" "terraform_pipeline" {

  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags
  pipeline_type = "V2"


  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeCommit"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        RepositoryName       = var.source_repo_name
        BranchName           = var.source_repo_branch
        PollForSourceChanges = "false"
      }
    }
  }


  stage {
    name = "Build-Image"
    dynamic "action" {
      for_each = var.stages
      content {
        category         = action.value["category"]
        name             = "Action-${action.value["name"]}"
        owner            = action.value["owner"]
        provider         = action.value["provider"]
        input_artifacts  = [action.value["input_artifacts"]]
        output_artifacts = [action.value["output_artifacts"]]
        version          = "1"
        run_order        = 2

        configuration = {
          ProjectName = action.value["provider"] == "CodeBuild" ? "${var.project_name}-${action.value["name"]}" : null
        }
      }
    }
  }
}