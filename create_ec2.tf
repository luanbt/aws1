//create 
resource "aws_vpc" "ownvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
}

// public subnet

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.ownvpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
}

// private subnet

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.ownvpc.id


    cidr_block = "192.168.1.0/24"
    availability_zone = "ap-south-1b"
}

// create public facing internet gateway
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.ownvpc.id
}

// create routing table for internet gateway
resource "aws_route_table" "my_table" {
  vpc_id = aws_vpc.ownvpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }

}
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.my_table.id
}

// creating security groups
resource "aws_security_group" "mywebsecurity" {
  name        = "my_web_security"
  description = "Allow http,ssh,icmp"
  vpc_id      =  aws_vpc.ownvpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  tags = {
    Name = "mywebserver_sg"
  }
}

// creating wordpress instance
resource "aws_instance" "wordpress" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
  key_name = "mynewkey"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "wordpress"
  }
}

// creating MySQL instance
resource "aws_instance" "mysql" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
  key_name = "mynewkey"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "mysql"
  }
}

// 
