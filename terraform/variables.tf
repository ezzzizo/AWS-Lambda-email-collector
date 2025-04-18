variable "ec2_type" {
  description = "The instance type for EC2"
  type        = string
}

variable "machine_name" {
  description = "The name of the EC2 instance"
  type        = string
}

variable "vpc_cidr" {
    description = "main vpc cidr-block"
    type = string
}

variable "subnet_cidr" {
    description = "main subnet cidr-block"
    type = string
}


variable "my_ip" {
    description = "my own ip used to ssh into ec2"
    type = string
}