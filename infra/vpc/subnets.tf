resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.custom_tags,
    {
      Name                                          = format("%s-public-%s", var.common_name, each.value.az_location),
      identifier                                    = local.identifier,
      "kubernetes.io/role/elb"                      = "1",
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.custom_tags,
    {
      Name                                          = format("%s-private-%s", var.common_name, each.value.az_location),
      identifier                                    = local.identifier,
      "kubernetes.io/role/internal-elb"             = "1",
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    }
  )
}
