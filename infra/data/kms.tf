resource "aws_kms_key" "this" {
  description         = "Key for encrypting RDS and SQS"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "this" {
  name          = "alias/data"
  target_key_id = aws_kms_key.this.key_id
}
