variable rds_username {
    sensitive   = true
    default       = "foo"
}

variable rds_password {
    sensitive   = true
}

variable database_name {
    type    = string
    default = "transactioncache"
}

variable bucket_name {
    type    = string
    default = "dms-test-20211211"
}