#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy" {

  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [module.ecr.arn]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.ecs_log_group.arn}:log-stream:*/*/*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_secretsmanager_secret.ecs_ado_pat.arn]
  }

  # temporal statement for test deployments
  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]

   #condition {
   #  test = "StringEquals"
   #  variable = "aws:RequestedRegion"
   #  values = [data.aws_region.current.name, "us-east-2"]
   #}
  }


}

# Lambda roles and policies
data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_create_task_role_policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    actions = [
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:RunTask"
    ]
    resources = ["${module.ecs.ecs_task_def_arn}:*"]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      module.iam_ecs_task_exec_role.aws_iam_role_arn,
      module.iam_ecs_task_role.aws_iam_role_arn
    ]
  }

  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.get_task_lambda.lambda_function_arn,
    ]
  }
}

data "aws_iam_policy_document" "lambda_get_task_role_policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    actions = [
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:GetTask"
    ]
    resources = [module.ecs.ecs_task_def_arn]
  }
  #arn:aws:ecs:eu-west-1:443307475174:task/ecs-ado-ecs-cluster-dev/
  statement {
    actions = [
      "ecs:DescribeTasks"
    ]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/${local.prefix}-ecs-cluster-${var.environment}/*"
    ]
  }
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      module.iam_ecs_task_exec_role.aws_iam_role_arn,
      module.iam_ecs_task_role.aws_iam_role_arn
    ]
  }


}

data "aws_iam_policy_document" "remote_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}



data "aws_iam_policy_document" "remote_state_role_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      var.remote_state_bucket_arn,
      "${ var.remote_state_bucket_arn}/*"
    ]
  }
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [var.remote_state_table_arn]
  }
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::${var.default_workload_account}:role/${var.terraform_project_name}-*"]
    effect = "Allow"
  }

}

# create policy document for  read only overall resources using readonly manage policy
data "aws_iam_policy_document" "readonly_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "readonly_state_role_policy" {
  statement {
    actions = [
     "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      values = [var.terraform_project_name]
      variable =  "aws:ResourceTag/Project"
    }
  }
  statement {
    actions = [
     "application-autoscaling:List*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt",
          "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:*:${var.default_workload_account}:key/*"] # todo change for multiple account using providers
    #resources = ["arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      values = [var.terraform_project_name]
      variable =  "aws:ResourceTag/Project"
    }
  }
}