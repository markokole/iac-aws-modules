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
		allocated_storage               = var.allocated_storage
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
    server_name      = var.source_server_name
    endpoint_id      = var.source_endpoint_id
    endpoint_type    = "source"
    engine_name      = var.source_engine_name
    database_name    = var.source_database_name
    port             = var.source_port
    username         = var.source_username
    password         = var.source_password 
}

resource aws_dms_endpoint target {
    endpoint_id     = var.target_endpoint_id
    engine_name     = "s3"
    endpoint_type   = "target"
    s3_settings {
        bucket_name             = var.target_bucket_name
        data_format             = var.target_s3_data_format
        service_access_role_arn = aws_iam_role.role.arn
        date_partition_enabled  = var.target_s3_date_partition_enabled
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
    table_mappings              = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"${var.source_database_name}\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
    replication_task_settings   = file(var.replication_task_settings)

    # lifecycle {
    #     ignore_changes = [replication_task_settings]
    # }
}