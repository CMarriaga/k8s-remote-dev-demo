resource "aws_security_group" "this" {
  name        = format("%s", var.common_name)
  description = format("Allow internal access to VPC Endpoints and RDS on the %s project", var.common_name)
  vpc_id      = var.vpc_id

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s", var.common_name),
      identifier = var.identifier,
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all TCP traffic from within the VPC"

  cidr_ipv4   = var.vpc_cidr_block
  from_port   = 0
  to_port     = 0
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all egress traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
