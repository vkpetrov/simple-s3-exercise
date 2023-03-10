##################################################################################
# CONFIGURATION
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "deep-dive"
  region  = var.aws_region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# DATA
##################################################################################

data "consul_keys" "apache" {
  key {
    name = "common_tags"
    path = "apache/configuration/common_tags"
  }
}


##################################################################################
# RESOURCES
##################################################################################

# Generate random ID for unique s3 bucket naming

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

##################################################################################
# LOCALS
##################################################################################

locals {
  s3_bucket_name = "dev-state-bucket-${random_integer.rand.result}"
  common_tags    = jsondecode(data.consul_keys.apache.var.common_tags)
}