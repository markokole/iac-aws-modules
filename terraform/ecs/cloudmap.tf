resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = replace(var.ecs_cluster_name, " ", "-")
  description = "Namespace for project ${var.ecs_cluster_name}"
  vpc         = var.vpc_id
}

# Service discovery service for Fargate only
resource "aws_service_discovery_service" "fargate" {
    for_each    = {for key, c in var.ecs_configuration : key => c
                   if c.launch_type == "FARGATE"}
    name        = "ecs-${each.key}-${lower(each.value.launch_type)}"

    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id
        dns_records {
            ttl  = 300
            type = "A"
        }
        routing_policy = "MULTIVALUE"
    }
    health_check_custom_config {
        failure_threshold = 1
    }
}


#
# Service discovery service for launch type EC2
# Container services on EC2 need a different approach - EC2 server's internal IP and port number must be registered
#
locals {
    
    ec2_service_name_keys = keys({for key, c in var.ecs_configuration : key => c if c.launch_type == "EC2"})
    number_ec2_services = length(local.ec2_service_name_keys)
    ec2_service_name = length(local.ec2_service_name_keys) > 0 ? element(local.ec2_service_name_keys, 0) : "dummy"
    
}

resource "aws_service_discovery_service" "ec2" {
    count = local.ec2_service_name == "dummy" ? 0 : 1
    name       = "ecs-${local.ec2_service_name}"

    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id
        dns_records {
            ttl  = 300
            type = "A"
        }
        routing_policy = "MULTIVALUE"
    }
    health_check_custom_config {
        failure_threshold = 1
    }
}

resource "aws_service_discovery_instance" "instances" {
  count = local.ec2_service_name == "dummy" ? 0 : 1
  instance_id = "id"
  service_id  = aws_service_discovery_service.ec2[0].id

  attributes = {
    AWS_INSTANCE_IPV4 = element(var.ec2_private_ips, 0)
    AWS_INSTANCE_PORT = element(var.ports_on_ec2, 0)
    
  }
}

output service_discovery_ecs {
    value = local.ec2_service_name == "dummy" ? [] : concat(
                [for f in aws_service_discovery_service.fargate : "${f.name}.${aws_service_discovery_private_dns_namespace.dns_namespace.name}"],
                ["${aws_service_discovery_service.ec2[0].name}.${aws_service_discovery_private_dns_namespace.dns_namespace.name}"]
            )
}