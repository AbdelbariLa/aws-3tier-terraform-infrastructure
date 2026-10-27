output "Private_Subnets_IDS" {
  value = aws_subnet.Private_Subnets[*].id
}

output "Public_Subnets_IDS" {
  value = aws_subnet.Public_Subnets[*].id
}

output "VPC_id" {
    value = aws_vpc.main.id 
}