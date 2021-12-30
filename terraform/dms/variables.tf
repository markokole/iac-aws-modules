variable project_name {
    type = string
    default = "Dev DMS"
}

variable vpc_id {
    type = string
    default = null
}

variable subnet_ids {
    type = list(string)
}

variable availability_zone {
    type = string
}

variable security_group_id {
    type = string
}

variable replication_instance_class {
    type        = string
    default     = "dms.t2.micro"
    description = "Can be one of dms.t2.micro, dms.t2.small, dms.t2.medium, dms.t2.large, dms.c4.large, dms.c4.xlarge, dms.c4.2xlarge, dms.c4.4xlarge"
}

variable server_name {}
variable database_name {}
variable port {}
variable endpoint_id {}
variable endpoint_type {}
variable engine_name {}
variable migration_type {}
variable username {
    sensitive = true
}
variable password {
    sensitive = true
}

variable permissions_boundary {
    type    = string
    default = ""
}

variable replication_task_settings {
    type    = string
}

variable allocated_storage {
    type    = number
    default = 20
}

#########
# target
#########

variable target_endpoint_id {
    type    = string
}

variable target_bucket_name {
    type = string
}

variable target_s3_data_format {
    type    = string
    default = "csv"
}

variable target_s3_date_partition_enabled {
    type    = string
    default = "false"
}