    resource "aws_db_subnet_group" "db_subnet" {
    name       = "main"
    subnet_ids = var.subnet_ids

    tags = {
        Name = var.project_name
    }
}

resource "aws_security_group_rule" "rds" {
    for_each = var.security_group_rules
    type              = "ingress"
    from_port         = each.value.port
    to_port           = each.value.port
    protocol          = "tcp"
    cidr_blocks       = each.value.cidr_blocks
    security_group_id = var.security_groups[0]  # TO-DO
    description       = each.value.description
}

resource "aws_db_instance" "default" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.micro"
    name                 = "mydb"
    username             = var.username
    password             = var.password
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true
    vpc_security_group_ids = var.security_groups
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name

    tags = {
        Name = var.project_name
    }
}