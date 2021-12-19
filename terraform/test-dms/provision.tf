module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "vpc" {
    source              = "../vpc"
    project_name        = "Migration"
}

module sg {
    source               = "../sg"
    vpc_id               = module.vpc.vpc_id
    security_group_name  = module.vpc.project_name

    security_group_rules = [
                            {
                            from_port = 0
                            to_port   = 0
                            protocol  = -1
                            self      = true
                            cidr_blocks = []
                            description = ""
                            },
                            {
                            from_port   = 22
                            to_port     = 22
                            protocol    = "tcp"
                            self        = false
                            cidr_blocks = ["${module.myip.address}/32"]
                            description = "Port 22 to local machine"
                            },
                            {
                            from_port   = 3306
                            to_port     = 3306
                            protocol    = "tcp"
                            self        = false
                            cidr_blocks = ["${module.myip.address}/32"]
                            description = "MySQL to local machine"
                            },
                            {
                            from_port   = 5432
                            to_port     = 5432
                            protocol    = "tcp"
                            self        = false
                            cidr_blocks = ["${module.myip.address}/32"]
                            description = "Postgres to local machine"
                            }
    ]
}

# locals {
#     user_data = <<EOF
# #!/bin/bash
# yum install -y telnet
# pip3 install mysql-connector-python --user
# EOF
# }


# module "ec2" {
#     source                      = "../ec2"
#     project_name                = module.vpc.project_name

#     ec2_data = {
#         public  = { instance_type               = "t3.medium"
#                     ami                         = "ami-04dd4500af104442f",
#                     subnet_id                   = module.vpc.subnet_public[0],
#                     availability_zone           = module.vpc.availability_zone[0],
#                     security_groups             = [module.sg.security_group_id],
#                     key_name                    = "markokey",
#                     associate_public_ip_address = true,
#                     user_data                   = local.user_data,
#                     iam_instance_profile        = null}
#     }
# }

module "rds" {
    source              = "../rds"
    project_name        = module.vpc.project_name
    vpc_id              = module.vpc.vpc_id
    username            = var.rds_username
    password            = var.rds_password
    publicly_accessible = "true"
    subnet_ids          = module.vpc.subnet_public
    security_groups     = [module.sg.security_group_id]
}


module dms {
    source              = "../dms"
    project_name        = module.vpc.project_name
    vpc_id              = module.vpc.vpc_id
    subnet_ids          = module.vpc.subnet_public
    availability_zone   = module.vpc.availability_zone[0]
    security_group_id   = module.sg.security_group_id
    migration_type      = "full-load-and-cdc"
    # migration_type      = "full-load"

    # make this for many
    server_name         = module.rds.address
    database_name       = "bank"
    # database_name       = "test"
    port                = module.rds.port
    endpoint_id         = module.rds.id
    endpoint_type       = "source"
    engine_name         = module.rds.engine
    username            = var.rds_username
    password            = var.rds_password
}
