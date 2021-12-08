variable project_name {
    description = "Project name all resources will be connected to."
    type = string
}

variable no_private_subnets {
    default = 1
    type = number

    validation {
        condition     = var.no_private_subnets == 1 || var.no_private_subnets == 2
        error_message = "Number of private ids can be either 1 or 2."
    }
}

variable no_public_subnets {
    default = 1
    type = number

    validation {
        condition     = var.no_public_subnets == 1 || var.no_public_subnets == 2
        error_message = "Number of public ids can be either 1 or 2."
    }
}

variable vpc_cidr_block {
    type = string
    default = "10.0.0.0/23"
}

locals {
    cidr_blocks = var.no_private_subnets == 2 ? cidrsubnets(var.vpc_cidr_block, 2, 2, 2) : cidrsubnets(var.vpc_cidr_block, 2, 2)
}