variable project_name {
    type = string
}

variable ec2_data {
  description = "EC2 configuration"
  type        = map
}

variable security_group_to_add_rule {
  description = "Security Group which gets a new rule"
  type        = string
}

variable security_group_rules {
    description = "Security group rules added for ECS containers"
    type = map
    default = {
        dummy = {
            port = 80
            cidr_blocks = ["127.0.0.0/32"]
            description = "Dummy port"
        }
    }
}