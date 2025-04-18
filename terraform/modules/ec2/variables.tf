variable "machine-name" {
    description = "name your ec2 instance"
    type = string
}

variable "ec2-type" {
    description = "type of your ec2 instance" 
    type = string
}

variable "subnet_id" {}
variable "security_group_id" {}