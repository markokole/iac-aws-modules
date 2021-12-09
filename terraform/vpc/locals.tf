locals {

    availability_zone_names = data.aws_availability_zones.available.names
    public_subnet_ids       = [for subnet in aws_subnet.public : subnet.id]
    private_subnet_ids      = [for subnet in aws_subnet.private : subnet.id]

    network_mask            = 23
    subnet_mask             = 27
    newbits                 = local.subnet_mask - local.network_mask

    cidr_amount             = 2*length(local.availability_zone_names)

    cidr_blocks             = [for index in range(local.cidr_amount):
                                cidrsubnet(var.vpc_cidr_block, local.newbits, index)]

    private_cidr_blocks     = slice(local.cidr_blocks, 0, local.cidr_amount/2)
    public_cidr_blocks      = slice(local.cidr_blocks, local.cidr_amount/2, local.cidr_amount)
}
