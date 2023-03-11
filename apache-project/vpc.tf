module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~>2.0"
  name               = "dev-apache"
  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = false
  tags               = local.common_tags
}