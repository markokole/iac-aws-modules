module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

resource random_password rds_password {
  length  = 8
  special = false
}

module "vpc" {
    source              = "../vpc"
    project_name        = "transactioncache"
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
                            }
    ]
}

# locals {
#     user_data = <<EOF
# #!/bin/bash
# yum install -y telnet 
# /usr/bin/pip3 install --target=/usr/lib64/python3.7/site-packages --upgrade sqlalchemy pymysql boto3 botocore
# EOF
# }

# module "ec2" {
#     source                      = "../ec2"
#     project_name                = module.vpc.project_name

#     ec2_data = {
#         public  = { instance_type               = "t3.micro"
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

# module "rds" {
#     source              = "../rds"
#     project_name        = module.vpc.project_name
#     db_identifier       = var.database_name
#     vpc_id              = module.vpc.vpc_id
#     username            = var.rds_username
#     password            = random_password.rds_password.result
#     publicly_accessible = "true"
#     subnet_ids          = module.vpc.subnet_public
#     security_groups     = [module.sg.security_group_id]
# }

module secretsmanager_iam {
    source              = "../iam"
    policy_name         = "secretsmanager-all-rds"
    policy_description  = "Read rds connection string secret"
    policy_action       = ["secretsmanager:CreateSecret",
                           "secretsmanager:GetSecretValue",
                           "secretsmanager:PutSecretValue",
                           "secretsmanager:DeleteSecret",
                           "secretsmanager:DescribeSecret", 
                           "secretsmanager:GetResourcePolicy"]
    policy_resource     = ["*"] #[module.rds_secretsmanager.arn]
    user                = "terraform"
}

# module rds_secretsmanager {
#     source          = "../secretsmanager"
#     secret_id       = module.rds.id
#     secret_string   = <<EOF
# {
#     "username": "${var.rds_username}",
#     "password": "${random_password.rds_password.result}",
#     "engine": "${module.rds.engine}",
#     "host": "${module.rds.address}",
#     "port": ${module.rds.port},
#     "dbClusterIdentifier": "${module.rds.id}"
# }
# EOF
#     depends_on = [module.secretsmanager_iam]
# }



# module dms {
#     source                      = "../dms"
#     project_name                = module.vpc.project_name
#     vpc_id                      = module.vpc.vpc_id
#     subnet_ids                  = module.vpc.subnet_public
#     availability_zone           = module.vpc.availability_zone[0]
#     security_group_id           = module.sg.security_group_id
#     migration_type              = "full-load-and-cdc"
#     replication_task_settings   = "${path.module}/resources/task_settings.json"

#     # make this for many
#     server_name         = module.rds.address
#     database_name       = var.database_name
#     port                = module.rds.port
#     endpoint_id         = module.rds.id
#     endpoint_type       = "source"
#     engine_name         = module.rds.engine
#     username            = var.rds_username
#     password            = var.rds_password
#     bucket_name         = var.bucket_name
# }
