resource "aws_ecs_cluster" "ecs" {
    name = replace(var.ecs_cluster_name, " ", "-")
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource aws_ecs_task_definition task_from_file {
    for_each = var.ecs_configuration
    family                      = each.key
    network_mode                = each.value.launch_type == "FARGATE" ? "awsvpc" : "bridge"
    requires_compatibilities    = [each.value.launch_type]
    cpu                         = each.value.cpu
    memory                      = each.value.memory
    container_definitions       = file(each.value.container_definitions)
    execution_role_arn          = data.aws_iam_role.ecs_task_execution_role.arn

    tags = {
        Name = each.key
    }
}

resource "aws_ecs_service" "service" {
    for_each = var.ecs_configuration
    name              = each.key
    cluster           = aws_ecs_cluster.ecs.id
    task_definition   = aws_ecs_task_definition.task_from_file[each.key].id
    desired_count     = 1
    launch_type       = each.value.launch_type
    platform_version  = each.value.launch_type == "FARGATE" ? "LATEST" : null

    # only for FARGATE launch type,
    # launch type EC2 has its service registered in the cloudmap directly
    dynamic service_registries {
        for_each = each.value.launch_type == "FARGATE" ? [1] : []
        content { 
            registry_arn    = aws_service_discovery_service.fargate[each.key].arn
            container_name  = "${each.key}-app"
        }
    }

    # block network_configuration is only used for network mode awsvpc (launch type FARGATE)
    # so it is ignored when launch type EC2, with network mode bridge, is in use
    dynamic network_configuration {
        for_each = each.value.launch_type == "FARGATE" ? [1] : []
        content { 
            assign_public_ip  = each.value.assign_public_ip
            security_groups   = var.security_groups
            subnets           = [var.subnet_id_public]

        }
    }

    lifecycle {
        ignore_changes = [task_definition]
    }
}