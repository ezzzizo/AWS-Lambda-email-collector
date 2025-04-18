variable "vpc-cidr" {
    description = "main vpc cidr-block"
    type = string
}

variable "subnet-cidr" {
    description = "main subnet cidr-block"
    type = string
}


variable "my-ip" {
    description = "my own ip used to ssh into ec2"
    type = string
}