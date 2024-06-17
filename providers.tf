terraform {
  required_providers {
    aws = {
      version = ">= 5.53.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.8.4"
  backend "s3" {
    bucket         = "daylightbucket12"
    key            = "ntier-aws/terraform"
    region         = "us-west-2"
    dynamodb_table = "mydbbackendtf"
  }

}

provider "aws" {
  region = "us-west-1"

}