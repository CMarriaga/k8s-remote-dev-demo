output "sqs_queue_url" {
  description = "Generated URL for the Queue"
  value       = aws_sqs_queue.this.url
}

output "rds_db_url" {
  description = "Generated URL for the database"
  value       = aws_db_instance.this.address
}
