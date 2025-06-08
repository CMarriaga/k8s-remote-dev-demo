resource "aws_vpc_endpoint" "rds" {
  vpc_id              = var.vpc_id
  service_name        = format("com.amazonaws.%s.rds", data.aws_region.this.name)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.eks_private_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = true

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-rds-endpoint", var.common_name),
      identifier = var.identifier,
    }
  )
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = var.vpc_id
  service_name        = format("com.amazonaws.%s.sqs", data.aws_region.this.name)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.eks_private_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = true

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-sqs-endpoint", var.common_name),
      identifier = var.identifier,
    }
  )
}
