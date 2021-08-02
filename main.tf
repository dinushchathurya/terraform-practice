provider "aws" {
    region  = "eu-west-1"
    shared_credentials_file = "/Users/admin/.aws/credentials"
    profile                 = "default"
}

# create vpc
resource "aws_vpc" "production-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="production"
    }
}

# create Internet Gateway
resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.production-vpc.id
}