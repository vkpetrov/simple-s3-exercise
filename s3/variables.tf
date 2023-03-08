##################################################################################
# VARIABLES
##################################################################################

variable "aws_region" {
  type        = string
  description = "Region for AWS Resources"
  default     = "us-east-1"
}

variable "consul_address" {
  type        = string
  description = "Local consul address"
  default     = "127.0.0.1"
}

variable "consul_port" {
  type        = string
  description = "Local consul port"
  default     = "8500"
}

variable "consul_datacenter" {
  type        = string
  description = "Local consul datacenter"
  default     = "dc1"
}

variable "access_ip" {
  type = string
  description = "Allow IP to access S3 object"
}