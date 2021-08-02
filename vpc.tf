provider "aws" {
    region  = "eu-west-1"
    shared_credentials_file = "/Users/admin/.aws/credentials"
    profile                 = "default"
}

resource "aws_vpc" "first_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="Production"
    }
}

resource "aws_subnet" "first_subnet" {
    vpc_id = aws_vpc.first_vpc.id
    cidr_block = "10.0.0.0/24"
    tags = {
        Name="production-subnet"
    }
}