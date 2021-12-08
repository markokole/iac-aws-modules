output project_name {
    value = var.project_name
}

output vpc_id {
    value = aws_vpc.vpc.id
}

output subnet_private {
    value = [for subnet in aws_subnet.private : subnet.id]
}

output subnet_public {
    value = [for subnet in aws_subnet.public : subnet.id]
}

output availability_zone_private {
    value = [for subnet in aws_subnet.private : subnet.availability_zone]
}

output availability_zone_public {
    value = [for subnet in aws_subnet.public : subnet.availability_zone]
}