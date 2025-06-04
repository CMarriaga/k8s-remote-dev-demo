data "aws_iam_policy_document" "kms" {
  statement {
    actions = ["kms:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["*"]
  }
}
