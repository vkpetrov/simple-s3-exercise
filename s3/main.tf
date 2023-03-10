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

data "consul_keys" "buckets" {
  key {
    name = "common_tags"
    path = "buckets/configuration/dev/common_tags"
  }
}

data "consul_keys" "config" {
  key {
    name = "access_ip"
    path = "config/access_ip"
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
  s3_bucket_name = "dev-bucket-${random_integer.rand.result}"
  access_ip      = jsondecode(data.consul_keys.config.var.access_ip)["access_ip"]
  common_tags = {
    "Environment" : "Dev",
    "Project" : "S3_Bucket"
  }
}