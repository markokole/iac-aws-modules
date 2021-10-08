output private_ips {
   value = [for ec2 in aws_instance.ec2 : ec2.private_ip]
}