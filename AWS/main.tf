terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

output "hello_aws" {
  value = "Hello from AWS account ${data.aws_caller_identity.current.account_id}"
}

module "naming" {
  source      = "../Shared/naming"
  project     = "sepf"
  environment = "dev"
  owner       = "julio"
  location    = "use1"
}



output "name_prefix" { value = module.naming.prefix }
output "tags" { value = module.naming.tags }

