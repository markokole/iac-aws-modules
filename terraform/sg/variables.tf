variable vpc_id {
    type = string
}

variable security_group_name {
    type = string
}

variable security_group_rules {
    description = "List of security group rules to be applied to the newly created security group"
}