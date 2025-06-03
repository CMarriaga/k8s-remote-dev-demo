resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-public-rt", var.common_name),
      identifier = local.identifier,
    }
  )
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.public_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-private-rt", var.common_name),
      identifier = local.identifier,
    }
  )
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.private_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
