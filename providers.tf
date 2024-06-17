terraform {
  required_providers {
    aws = {
      version = ">= 5.53.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.8.4"
  backend "s3" {
    bucket = "backendfirstbucket"
    key = "ntier/backend"
    region = "ap-south-1"
    dynamodb_table = "firstdynamodblock"
  }
  
}

provider "aws" {
  region = "us-west-1"

}