variable ecs_cluster_name {
    type = string
}

variable vpc_id {
    type = string
}

variable ecs_configuration {
  description = "ECS configuration for tasks and services"
  type        = map
}

variable security_groups {
    type = list(string)
}

variable subnet_id_private {
    type = string
}

variable subnet_id_public {
    type = string
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