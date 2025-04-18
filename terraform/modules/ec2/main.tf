#                       _____________________
#                      |.....................|
#                      |  EC2  (Web server)  |
#                      |_____________________|


#data "aws_ami" "linux" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}


resource "aws_key_pair" "server-key" {    # coniguring an SSH key pair
  key_name   = "server-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {        # Generating RSA public key
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa" {             # storing the public key in a (.pem) file
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey.pem"
}

resource "aws_instance" "main_machine" {
    ami =  "ami-071226ecf16aa7d96"                 #data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.ec2-type
    
    subnet_id = var.subnet_id
    associate_public_ip_address = true
    vpc_security_group_ids = [var.security_group_id]
    key_name = "server-key"

    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                EOF

    #iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name


    tags = {
        Name = var.machine-name
  }
}