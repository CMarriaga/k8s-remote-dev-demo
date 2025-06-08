resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.custom_tags,
    each.value.eks_subnet ? {
      Name                                          = format("%s-eks-public-%s", var.common_name, each.value.az_location),
      stack                                         = "eks"
      "kubernetes.io/role/elb"                      = "1",
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
      } : {
      Name  = format("%s-data-public-%s", var.common_name, each.value.az_location),
      stack = "data"
    },
    {
      identifier = local.identifier,
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.custom_tags,
    each.value.eks_subnet ? {
      Name                                          = format("%s-eks-private-%s", var.common_name, each.value.az_location),
      stack                                         = "eks"
      "kubernetes.io/role/internal-elb"             = "1",
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
      } : {
      Name  = format("%s-data-private-%s", var.common_name, each.value.az_location),
      stack = "data"
    },
    {
      identifier = local.identifier,
    }
  )
}
