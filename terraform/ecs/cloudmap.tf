resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = replace(var.ecs_cluster_name, " ", "-")
  description = "Namespace for project ${var.ecs_cluster_name}"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "services" {
  for_each   = toset(keys(var.ecs_configuration))
  name       = each.key

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