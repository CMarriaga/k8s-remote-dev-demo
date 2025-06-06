locals {
  cluster_name = var.cluster_name
  identifier   = var.identifier
  vpc_id       = aws_vpc.this.id
  private_subnets = { for k, v in var.private_subnets : v.cidr => {
    cidr        = v.cidr
    az          = v.az
    az_location = substr(v.az, length(v.az) - 1, 1)
    eks_subnet  = v.eks_subnet
    }
  }
  public_subnets = { for k, v in var.public_subnets : v.cidr => {
    cidr        = v.cidr
    az          = v.az
    az_location = substr(v.az, length(v.az) - 1, 1)
    eks_subnet  = v.eks_subnet
    }
  }
  public_subnet_ids  = [for subnet in aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}
