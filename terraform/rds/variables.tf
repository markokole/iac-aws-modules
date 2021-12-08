variable project_name {
    type = string
}

variable username {
    type = string
}

variable password {
    type = string
}

variable publicly_accessible {
    type = string
}


variable subnet_ids {
    type = list(string)
}

variable security_groups {
    type = list(string)
}

variable security_group_rules {
    description = "Security group rules added for RDS"
    type = map
    default = {
        dummy = {
            port = 80
            cidr_blocks = ["127.0.0.0/32"]
            description = "Dummy port"
        }
    }
}