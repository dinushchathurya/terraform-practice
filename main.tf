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

# create Route table
resource "aws_route_table" "production-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "production"
  }
}

# create subnet
resource "aws_subnet" "production-subnet" {
    vpc_id = aws_vpc.production-vpc.id
    cidr_block = "10.0.1.0/24"
    avaliabilty_zone = "eu-west-1a"
    tags = {
        Name="production-subnet"
    }
}

# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.production-subne.id
  route_table_id = aws_route_table.production-route-table.id
}