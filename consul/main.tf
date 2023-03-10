##################################################################################
# TERRAFORM CONFIG
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~>2.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
  profile = "deep-dive"
}

provider "consul" {
  address    = "127.0.0.1:8500"
  datacenter = "dc1"
}

##################################################################################
# RESOURCES
##################################################################################

resource "consul_keys" "buckets" {
  key {
    path  = "buckets/configuration/"
    value = ""
  }
  key {
    path  = "buckets/state/"
    value = ""
  }
}

resource "consul_keys" "ip_config" {
  key {
    path = "config/"
    value = ""
  }
}

resource "consul_keys" "apache" {
  key {
    path = "apache/configuration/"
    value = ""
  }
}
resource "consul_acl_policy" "buckets" {
  name  = "buckets"
  rules = <<-RULE
    key_prefix "buckets" {
      policy = "write"
    }

    session_prefix "" {
      policy = "write"
    }

    RULE
}

resource "consul_acl_token" "buckets" {
  description = "token for managing s3 buckets"
  policies    = [consul_acl_policy.buckets.name]
}