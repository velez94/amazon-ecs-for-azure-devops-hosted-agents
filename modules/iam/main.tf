resource "aws_iam_role" "iam_role" {
  name                  = var.iam_role_name
  assume_role_policy    = var.iam_assume_role_policy
  #managed_policy_arns = var.iam_managed_policy_arns
}
 
resource "aws_iam_policy" "iam_role_policy" {
  name          = var.iam_role_name
  description   = "Policy that allows access to IAM role created with aws_iam_role.iam_role"
  policy        = var.iam_role_policy
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role          = aws_iam_role.iam_role.name
  policy_arn    = aws_iam_policy.iam_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "policy-attachments" {
  count = var.iam_managed_policy_arns != null ? length(var.iam_managed_policy_arns) : 0
  role          = aws_iam_role.iam_role.name
  policy_arn    = var.iam_managed_policy_arns[count.index]
}
