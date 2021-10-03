module "vpc" {
    source            = "../vpc"
    project_name      = "Test ECS"
}

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
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
                            from_port   = 6379
                            to_port     = 6379
                            protocol    = "tcp"
                            self        = false
                            cidr_blocks = ["${module.myip.address}/32"]
                            description = "Redis"
                            }
    ]
}

module "ec2" {
    source                      = "../ec2"
    project_name                = module.vpc.project_name

    ec2_data = {
        public  = { instance_type               = "t3.medium"
                    ami                         = "ami-0baa9e2e64f3c00db",
                    subnet_id                   = module.vpc.subnet_public,
                    availability_zone           = module.vpc.availability_zone_public,
                    security_groups             = [module.sg.security_group_id],
                    key_name                    = "markokey",
                    associate_public_ip_address = true,
                    user_data = ""}
    }
}

module "ecs" {
    source              = "../ecs"
    ecs_cluster_name    = module.vpc.project_name
    vpc_id              = module.vpc.vpc_id

    ecs_configuration = {
        nginx = {
            # task
            cpu                     = 512
            memory                  = 2048
            container_definitions   = "resources/ecs-task-definitions/nginx.json"
            assign_public_ip        = true
        },
        redis = {
            # task
            cpu                     = 512
            memory                  = 2048
            container_definitions   = "resources/ecs-task-definitions/redis.json"
            assign_public_ip        = false
        }
    }

    security_groups     = [module.sg.security_group_id]
    subnet_id_private   = element(module.vpc.subnet_private, 0)
    subnet_id_public    = module.vpc.subnet_public
}

output cloudmap_services {
    value = formatlist("%s.${keys(module.ecs)[0]}", module.ecs["ecs_services"])
}
