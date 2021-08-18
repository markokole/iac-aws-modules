variable project_name {
    type = string
}

variable ami {
    type = string
}

variable instance_type {
    type = string
}

variable subnet {
    type = string
}

variable availability_zone {
    type = string
}

variable security_groups {
    type = list(string)
}
variable key_name {
    type = string
}
variable associate_public_ip_address {
    type = bool
}

variable ec2_tag_name {
    type = string
}