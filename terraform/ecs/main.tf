resource "aws_ecs_cluster" "ping" {
    name = replace(var.ecs_cluster_name, " ", "-")

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_task_definition" "task_from_file" {
    for_each = var.ecs_configuration
    family                      = "family-${each.key}"
    network_mode                = "awsvpc"
    requires_compatibilities    = ["FARGATE", "EC2"]
    cpu                         = each.value.cpu
    memory                      = each.value.memory
    container_definitions       = file(each.value.container_definitions)

    tags = {
        Name = each.key
    }
}

resource "aws_security_group_rule" "redis" {
    for_each = var.security_group_rules
    type              = "ingress"
    from_port         = each.value.port
    to_port           = each.value.port
    protocol          = "tcp"
    cidr_blocks       = each.value.cidr_blocks
    security_group_id = var.security_groups[0]  # TO-DO
    description       = each.value.description
}

resource "aws_ecs_service" "service" {
    for_each = var.ecs_configuration
    name              = "service-${each.key}"
    cluster           = aws_ecs_cluster.ping.id
    task_definition   = aws_ecs_task_definition.task_from_file[each.key].id
    desired_count     = 1
    launch_type       = "FARGATE"
    platform_version  = "LATEST"

    service_registries {
        registry_arn    = aws_service_discovery_service.services[each.key].arn
        container_name  = "${each.key}-app"
  }

    network_configuration {
        assign_public_ip  = each.value.assign_public_ip
        security_groups   = var.security_groups
        subnets           = [each.value.subnet_id]
    }
    lifecycle {
        ignore_changes = [task_definition]
    }
}