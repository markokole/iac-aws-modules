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
