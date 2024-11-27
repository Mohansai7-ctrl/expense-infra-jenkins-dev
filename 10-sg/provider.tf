terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket = "mohan-remote-state-dev"
        dynamodb_table = "mohan-locking-dev"
        key = "expense-sg"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}