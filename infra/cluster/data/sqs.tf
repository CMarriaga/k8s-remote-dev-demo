resource "aws_sqs_queue" "this" {
  name                       = format("%s-queue", var.common_name)
  kms_master_key_id          = aws_kms_key.this.key_id
  visibility_timeout_seconds = 30

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-queue", var.common_name),
      identifier = var.identifier,
    }
  )
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.sqs.json
}
