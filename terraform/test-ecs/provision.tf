locals {
  project_name = "Test ECS"

  ecs_configuration = {
        nginx_ec2 = {
            # task
            cpu                     = 512
            memory                  = 2048
            container_definitions   = "resources/ecs-task-definitions/nginx.json"
            assign_public_ip        = false
            launch_type             = "EC2"
        },
        nginx_fargate = {
            # task
            cpu                     = 512
            memory                  = 2048
            container_definitions   = "resources/ecs-task-definitions/nginx.json"
            assign_public_ip        = true
            launch_type             = "FARGATE"
        }
    }
}

module vpc {
    source              = "../vpc"
    project_name        = local.project_name
}

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

#
# Security group
#
module sg {
    source              = "../sg"
    vpc_id              = module.vpc.vpc_id
    security_group_name = "${local.project_name} SG"

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
                            from_port   = 80
                            to_port     = 80
                            protocol    = "tcp"
                            self        = false
                            cidr_blocks = ["${module.myip.address}/32"]
                            description = "Port 80 to local machine"
                            }
    ]
}

#
# EC2 instance for ECS services
#
module "ec2_ecs" {
    depends_on = [module.vpc]
    source                      = "../ec2"
    project_name                = module.vpc.project_name

    ec2_data = {
        docker = { instance_type               = "t3.medium"
                    ami                         = "ami-07f7406f695da2194",
                    subnet_id                   = module.vpc.subnet_public,
                    availability_zone           = module.vpc.availability_zone_public,
                    security_groups             = [module.sg.security_group_id],
                    key_name                    = "markokey",
                    associate_public_ip_address = true,
                    iam_instance_profile        = "ecsInstanceRole"
                    user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${replace(local.project_name, " ", "-")} >> /etc/ecs/ecs.config"
                }
    }
}

#
# ECS Service with one Fargate and one EC2 launch type
#
module "ecs" {
    depends_on = [module.ec2_ecs]
    source              = "../ecs"
    ecs_cluster_name    = module.vpc.project_name
    vpc_id              = module.vpc.vpc_id

    ecs_configuration = local.ecs_configuration

    security_groups     = [module.sg.security_group_id]
    subnet_id_private   = element(module.vpc.subnet_private, 0)
    subnet_id_public    = module.vpc.subnet_public
    ec2_private_ips     = module.ec2_ecs.private_ips
}

output service_discovery_ecs {
    value = module.ecs.service_discovery_ecs
}
