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
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "production"
  }
}

# create subnet
resource "aws_subnet" "production-subnet" {
    vpc_id = aws_vpc.production-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name="production-subnet"
    }
}

# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.production-subnet.id
  route_table_id = aws_route_table.production-route-table.id
}

# create security group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }
  
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# create network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.production-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# create ELastic ip
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gateway]
}

# create Ubuntu server and install apache
resource "aws_instance" "web-server-instance" {
    ami           = "ami-0a8e758f5e873d1c1"
    instance_type = "t2.micro"
    availability_zone = "eu-west-1a"
    key_name= "terraform"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c "echo first web server > /var/www/html/index.html"
        EOF
    tags = {
        "Name" = "production-ec2"
    }
}