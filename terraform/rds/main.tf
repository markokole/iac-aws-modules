    resource "aws_db_subnet_group" "db_subnet" {
    name       = "main"
    subnet_ids = var.subnet_ids

    tags = {
        Name = var.project_name
    }
}

resource aws_db_parameter_group parameters {
    name          = "dms-mysql-parameters"
    family        = "mysql5.7"
    description   = "Group for specifying binary log settings for replication"

    parameter {
        name  = "binlog_checksum"
        value = "NONE"
    }
    parameter {
        name  = "binlog_format"
        value = "ROW"
    }
    parameter {
        name  = "binlog_row_image"
        value = "FULL"
    }
}

resource aws_db_instance instance {
    allocated_storage       = 10
    engine                  = "mysql"
    engine_version          = "5.7"
    backup_retention_period = 3
    apply_immediately       = true
    # auto_minor_version_upgrade = false #to-do: test DMS with these two as well!!!
    # monitoring_interval = 0
    instance_class          = var.instance_class
    name                    = var.database_name
    username                = var.username
    password                = var.password
    publicly_accessible     = var.publicly_accessible
    parameter_group_name    = aws_db_parameter_group.parameters.name
    skip_final_snapshot     = true
    vpc_security_group_ids  = var.security_groups
    db_subnet_group_name    = aws_db_subnet_group.db_subnet.name

    tags = {
        Name = var.project_name
    }
}