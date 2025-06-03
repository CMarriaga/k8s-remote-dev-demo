resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-igw", var.common_name),
      identifier = local.identifier,
    }
  )
}

resource "aws_eip" "this" {
  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-eip", var.common_name),
      identifier = local.identifier,
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = local.public_subnet_ids[0]

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-nat", var.common_name),
      identifier = local.identifier,
    }
  )

  depends_on = [
    aws_internet_gateway.this,
    aws_subnet.public
  ]
}
