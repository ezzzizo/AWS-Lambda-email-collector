output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "subnet_id" {
  value = aws_subnet.main-subnet.id
}

output "security_group_id" {
  value = aws_default_security_group.main-sg.id
}