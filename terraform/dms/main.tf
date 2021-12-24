resource "aws_dms_replication_subnet_group" "subnet" {
  	replication_subnet_group_description = var.project_name
  	replication_subnet_group_id          = "${lower(replace(var.project_name, " ", "-"))}-replication-subnet-group-tf"

	subnet_ids = var.subnet_ids

	tags = {
		Name = var.project_name
	}
}

# Create a new replication instance
resource "aws_dms_replication_instance" "instance" {
		allocated_storage               = 20
		apply_immediately               = true
		auto_minor_version_upgrade      = true
		availability_zone               = var.availability_zone
		engine_version                  = "3.4.6"
		# kms_key_arn                   = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
		multi_az                        = false
		preferred_maintenance_window    = "sun:10:30-sun:14:30"
		publicly_accessible             = true
		replication_instance_class      = var.replication_instance_class
		replication_instance_id         = "${lower(replace(var.project_name, " ", "-"))}-replication-instance-tf"
		replication_subnet_group_id     = aws_dms_replication_subnet_group.subnet.id
		vpc_security_group_ids          = [var.security_group_id]

		tags = {
			Name = var.project_name
		}
}

resource aws_dms_endpoint source {
    server_name                 = var.server_name
    endpoint_id                 = var.endpoint_id
    endpoint_type               = var.endpoint_type
    engine_name                 = var.engine_name
    database_name               = var.database_name
    port                        = var.port
    username                    = var.username
    password                    = var.password 
}

resource aws_dms_endpoint target {
    endpoint_type               = "target"
    endpoint_id                 = "target-s3"
    engine_name                 = "s3"
    s3_settings {
        bucket_name             = var.bucket_name
        data_format             = var.s3_data_format
        service_access_role_arn = aws_iam_role.role.arn
    }

    depends_on = [
        aws_iam_role.role
    ]
}

resource aws_dms_replication_task task {
    migration_type              = var.migration_type
    replication_instance_arn    = aws_dms_replication_instance.instance.replication_instance_arn
    replication_task_id         = "replication-task-id"
    source_endpoint_arn         = aws_dms_endpoint.source.endpoint_arn
    target_endpoint_arn         = aws_dms_endpoint.target.endpoint_arn
    table_mappings              = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"${var.database_name}\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
    replication_task_settings   = file(var.replication_task_settings)

    # lifecycle {
    #     ignore_changes = [replication_task_settings]
    # }
}