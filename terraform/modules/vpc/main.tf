#                       _______
#                      |.......|
#                      |  vpc  |
#                      |_______|


resource "aws_vpc" "main-vpc" {
    cidr_block = var.vpc-cidr
    
    tags = {
      Name = "main-vpc" 
    }
}

resource "aws_subnet" "main-subnet" {
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = var.subnet-cidr

    tags = {
      Name = "subnet-1"
    }
}


resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.main-vpc.id

    tags = {
      Name = "web-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.main-vpc.default_route_table_id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main-igw.id
    }

    tags = {
      Name = "main-rtb"
    }
}

resource "aws_default_security_group" "main-sg" {         # configuring a security group to restrict inbound and outbound traffic
    vpc_id = aws_vpc.main-vpc.id

    ingress {
      from_port = 22   # SSH
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.my-ip]
    }

    ingress {
      from_port = 80   # HTTP
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
    }

    tags = {
      Name = "main-default-sg"
    }
}
