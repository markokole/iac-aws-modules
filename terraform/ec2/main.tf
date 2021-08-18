resource "aws_instance" "ec2" {
    ami                         = var.ami
    instance_type               = var.instance_type
    subnet_id                   = var.subnet
    vpc_security_group_ids      = var.security_groups
    availability_zone           = var.availability_zone
    key_name                    = var.key_name
    associate_public_ip_address = var.associate_public_ip_address
    tags = {
        "Name" = var.project_name
    }
}

output ec2_public_ip {
   value = length(aws_instance.ec2) > 0 ? aws_instance.ec2.public_ip : ""
}

# resource "aws_instance" "private" {
#     count                       = 0
#     ami                         = "ami-0baa9e2e64f3c00db"  # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
#     instance_type               = "t3.medium"
#     subnet_id                   = var.subnet_private # aws_subnet.private.id
#     vpc_security_group_ids      = var.security_groups #[aws_security_group.sg.id]
#     availability_zone           = var.availability_zone_private # aws_subnet.private.availability_zone
#     key_name                    = "markokey"
#     associate_public_ip_address = "true"
#     tags = {
#         "Name" = "Private"
#     }
# }

# output private_ip {
#    value = length(aws_instance.private) > 0 ? aws_instance.private[0].private_ip : ""
# }