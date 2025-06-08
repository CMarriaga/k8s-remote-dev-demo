# resource "aws_s3_bucket" "loki" {
#   bucket        = format("%s-loki", var.common_name)
#   force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "loki" {
#   bucket                  = aws_s3_bucket.loki.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
