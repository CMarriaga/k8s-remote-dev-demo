data "aws_iam_policy_document" "demo" {
  statement {
    actions   = ["sqs:*", "rds:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "demo" {
  name        = "irsa-demo-aws-access"
  path        = "/"
  description = "Role to be used by the app to access SQS and RDS"
  policy      = data.aws_iam_policy_document.demo.json
}
