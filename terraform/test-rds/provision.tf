module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "vpc" {
    source              = "../vpc"
    project_name        = "Test RDS Module"
}

module sg {
    source              = "../sg"
    vpc_id              = module.vpc.vpc_id
    security_group_name = "EC2 SG"

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
                            }
    ]
}

locals {
    user_data = <<EOF
#!/bin/bash
yum install -y telnet
pip3 install mysql-connector-python --user
EOF
}


module "ec2" {
    source                      = "../ec2"
    project_name                = module.vpc.project_name

    ec2_data = {
        public  = { instance_type               = "t3.medium"
                    ami                         = "ami-04dd4500af104442f",
                    subnet_id                   = module.vpc.subnet_public[0],
                    availability_zone           = module.vpc.availability_zone[0],
                    security_groups             = [module.sg.security_group_id],
                    key_name                    = "markokey",
                    associate_public_ip_address = true,
                    user_data                   = local.user_data,
                    iam_instance_profile        = null}
    }
}

module "rds" {
    source              = "../rds"
    project_name        = module.vpc.project_name
    username            = "foo"
    password            = "rR5Yq_5tS"
    publicly_accessible = "true"
    subnet_ids          = module.vpc.subnet_public
    security_groups     = [module.sg.security_group_id]


    security_group_rules = {
        mysql = {
            port = 3306
            cidr_blocks = ["${module.myip.address}/32"]
            description = "MySQL port"
        }
    }
}
