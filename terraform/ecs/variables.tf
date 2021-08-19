variable ecs_cluster_name {
    type = string
}

variable ecs_configuration {
  description = "ECS configuration for tasks and services"
  type        = map
}

variable security_groups {
    type = list(string)
}

# variable public_subnet_id {
#     type = string
# }

# variable private_subnet_id {
#     type = string
# }

variable security_group_rules {
    description = "Security group rules added for ECS containers"
    type = map
}