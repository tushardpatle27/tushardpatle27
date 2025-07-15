data "aws_availability_zones" "available" {}
 
locals {
  newbits = 8
  netcount = 6
  all_subnets = [for i in range(local.netcount) : cidrsubnet(var.vpc_cidr, local.newbits, i)]
  public_subnets  = slice(local.all_subnets, 0, 3)
  private_subnets = slice(local.all_subnets, 3, 6)
}
 
# vpc module to create vpc, subnets, NATs, IGW etc..
module "vpc_and_subnets" {
  # invoke public vpc module
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
 
  # vpc name
  name = var.name
 
  # availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
 
  # vpc cidr
  cidr = var.vpc_cidr
 
  # public and private subnets
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
 
  # create nat gateways
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
 
  # enable dns hostnames and support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
 
  # tags for public, private subnets and vpc
  tags                = var.tags
  public_subnet_tags  = var.additional_public_subnet_tags
  private_subnet_tags = var.additional_private_subnet_tags
 
  # create internet gateway
  create_igw       = var.create_igw
  instance_tenancy = var.instance_tenancy
 
}
