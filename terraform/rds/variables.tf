variable vpc_id {
    type = string
}
variable project_name {
    type = string
}

variable username {
    type = string
}

variable password {
    type = string
}

variable publicly_accessible {
    type = string
}

variable subnet_ids {
    type = list(string)
}

variable security_groups {
    type = list(string)
}

variable instance_class {
    type    = string
    default = "db.t3.micro"
}

variable database_name {
    type    = string
    default = "mydb"
}

variable storage_encrypted {
    type    = string
    default = "true"
}

variable allocated_storage {
    type    = number
    default = 10
}

variable engine {
    type    = string
    default = "mysql"
}

variable engine_version {
    type    = string
    default = "5.7"
}

variable backup_retention_period {
    type    = number
    default = 3
}

variable apply_immediately {
    type    = string
    default = "true"
}

variable skip_final_snapshot {
    type    = string
    default = "true"
}

variable tags {
    type    = map(string)
    default = {}
}