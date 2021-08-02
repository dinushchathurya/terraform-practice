provider "aws" {
    region  = "eu-west-1"
    shared_credentials_file = "/Users/admin/.aws/credentials"
    profile                 = "default"
}

# create vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="main"
    }
}