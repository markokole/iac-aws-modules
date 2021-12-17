    resource "aws_db_subnet_group" "db_subnet" {
    name       = "main"
    subnet_ids = var.subnet_ids

    tags = {
        Name = var.project_name
    }
}

# resource aws_db_parameter_group parameters {
#   name          = "dms-mysql-parameters"
#   family        = "mysql8.0"
#   description   = "Group for specifying binary log settings for replication"

#   parameter {
#     name  = "binlog_checksum"
#     value = "NONE"
#   }
#   parameter {
#     name  = "binlog_format"
#     value = "ROW"
#   }
# }

resource aws_db_instance instance {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = var.instance_class
    name                 = var.database_name
    username             = var.username
    password             = var.password
    publicly_accessible  = var.publicly_accessible
    parameter_group_name = "default.mysql5.7"
    # parameter_group_name = aws_db_parameter_group.parameters.name
    skip_final_snapshot  = true
    vpc_security_group_ids = var.security_groups
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name

    tags = {
        Name = var.project_name
    }
}