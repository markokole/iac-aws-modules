variable project_name {
    description = "Project name all resources will be connected to."
    type = string
}

variable no_private_subnets {
    default = 1
    type = number
}

variable vpc_cidr_block {
    type = string
    default = "10.0.0.0/23"
}

locals {
    cidr_blocks = var.no_private_subnets == 2 ? cidrsubnets(var.vpc_cidr_block, 2, 2, 2) : cidrsubnets(var.vpc_cidr_block, 2, 2)
}