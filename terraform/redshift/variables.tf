variable cluster_identifier {
    type = string
}

variable cluster_type {
    type = string

    validation {
        condition     = contains(["single-node", "multi-node"], var.cluster_type)
        error_message = "Valid values for cluster type er single-node or multi-node."
    }
}

variable master_username {
    type = string
}

variable master_password {
    type = string
}

variable subnet_ids {
    type = list(string)
}

variable vpc_security_group_ids {
    type = list(string)
}

variable availability_zone {
    type = string
}

variable my_ip {
    type    = string
    default = "127.0.0.1"
}

variable security_group_rules {
    description = "Security group rules added for Redshift"
    type = map
    default = {
        dummy = {
            port = 80
            cidr_blocks = ["127.0.0.0/32"]
            description = "Dummy port"
        }
    }
}
