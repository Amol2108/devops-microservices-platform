variable "env" {
  description = "Environment name"
  type        = string
}
terraform {
  backend "s3" {
    bucket         = "devops-terraform-state-ironman21"
    key            = "devops-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "devops_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id= aws_vpc.main_vpc.id
    cidr_block= "10.0.1.0/24"
    map_public_ip_on_launch = true

    availability_zone = "ap-south-1a" 

    tags = {
        Name= "public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id= aws_vpc.main_vpc.id
    cidr_block= "10.0.2.0/24"

    tags = {
        Name= "private_subnet"
    }
}

resource "aws_security_group" "devops-sg"{
    name= "devops-sg"
    description= "Allow ssh, HTTP , App ports"
    vpc_id= aws_vpc.main_vpc.id

    ingress {
        description = "ssh"
        from_port = 22
        to_port= 22
        protocol= "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "Frontend"
        from_port = 3000
        to_port= 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description= "Backend"
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description= "HTTP"
        from_port = 80
        to_port= 80
        protocol= "tcp"
        cidr_blocks= ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks= ["0.0.0.0/0"]
    }

    tags = {
        Name= "devops_sg"
    }
}
resource "aws_instance" "devops_ec2" {
  ami           = "ami-048f4445314bcaa09"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name = "devops-key"

  vpc_security_group_ids = [aws_security_group.devops-sg.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker

docker pull ironman21/backend-app:v1
docker pull ironman21/frontend-app:v1

docker network inspect my-network >/dev/null 2>&1 || docker network create my-network

docker rm -f backend-container || true
docker run -d --restart always -p 5000:5000 --name backend-container --network my-network ironman21/backend-app:v1
docker rm -f frontend-container || true
docker run -d --restart always -p 3000:3000 --name frontend-container --network my-network ironman21/frontend-app:v1
EOF

  tags = {
    Name = "devops-${var.env}-ec2"
  }
}


resource "aws_internet_gateway" "igw" {
    vpc_id= aws_vpc.main_vpc.id

    tags = {
        Name= "devops_igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block= "0.0.0.0/0"
        gateway_id= aws_internet_gateway.igw.id
    }

    tags = {
        Name= "public-route-table"
    }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

output "ec2_public_ip" {
    value= aws_instance.devops_ec2.public_ip
}
output "vpc_id" {
    value= aws_vpc.main_vpc.id
}
output "public_subnet_id" {
    value= aws_subnet.public_subnet.id
}