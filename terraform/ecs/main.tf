resource "aws_ecs_cluster" "ecs" {
    name = replace(var.ecs_cluster_name, " ", "-")

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource aws_ecs_task_definition task_from_file {
    for_each = var.ecs_configuration
    family                      = each.key
    network_mode                = "awsvpc"
    requires_compatibilities    = ["FARGATE", "EC2"]
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
    launch_type       = "FARGATE"
    platform_version  = "LATEST" # "1.43.0"

    service_registries {
        registry_arn    = aws_service_discovery_service.services[each.key].arn
        container_name  = "${each.key}-app"
  }

    network_configuration {
        assign_public_ip  = each.value.assign_public_ip
        security_groups   = var.security_groups
        subnets           = [each.value.assign_public_ip == true ? var.subnet_id_public : var.subnet_id_private]
    }
    lifecycle {
        ignore_changes = [task_definition]
    }
}