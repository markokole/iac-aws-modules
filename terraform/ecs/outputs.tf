output ecs_services {
    value = keys(var.ecs_configuration)
}

output cluster_name {
    value = aws_ecs_cluster.ecs.name
}