resource "aws_redshift_subnet_group" "subnet" {
  name       = lower(replace(var.cluster_identifier, " ", "-"))
  subnet_ids = var.subnet_ids

  tags = {
    environment = "Production"
  }
}

resource "aws_security_group_rule" "redshift" {
    for_each = var.security_group_rules
    type              = "ingress"
    from_port         = each.value.port
    to_port           = each.value.port
    protocol          = "tcp"
    cidr_blocks       = each.value.cidr_blocks
    security_group_id = var.vpc_security_group_ids[0]  # TO-DO
    description       = each.value.description
}

resource "aws_redshift_cluster" "cluster" {
    cluster_identifier = lower(replace(var.cluster_identifier, " ", "-"))
    database_name      = "mydb"
    master_username    = var.master_username
    master_password    = var.master_password
    node_type          = "dc2.large"
    cluster_type       = var.cluster_type
    skip_final_snapshot= true

    vpc_security_group_ids    = var.vpc_security_group_ids
    cluster_subnet_group_name = aws_redshift_subnet_group.subnet.id
    availability_zone         = var.availability_zone
}