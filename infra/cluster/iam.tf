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

# data "aws_iam_policy_document" "loki_s3" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:ListBucket",
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject"
#     ]
#     resources = [
#       aws_s3_bucket.loki.arn,
#       "${aws_s3_bucket.loki.arn}/*"
#     ]
#   }
# }

# resource "aws_iam_policy" "loki_s3" {
#   name   = "loki-s3-access"
#   policy = data.aws_iam_policy_document.loki_s3.json
# }
