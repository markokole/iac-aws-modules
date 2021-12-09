variable project_name {
    default = "Dev"
    description = "Project name all resources will be connected to."
    type = string
}

variable vpc_cidr_block {
    type = string
    default = "10.0.0.0/23"
}
 