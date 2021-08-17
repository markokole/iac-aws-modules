output security_group {
  value = aws_security_group.sg.id
}

output subnet_private {
    value = aws_subnet.private.id
}

output subnet_public {
    value = aws_subnet.public.id
}

output availability_zone_private {
    value = aws_subnet.private.availability_zone
}

output availability_zone_public {
    value = aws_subnet.public.availability_zone
}