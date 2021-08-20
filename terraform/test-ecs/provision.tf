module "vpc" {
    source            = "../vpc"
    project_name      = "Test ECS"
}

module "ec2" {
    source                      = "../ec2"
    project_name                = module.vpc.project_name

    ec2_data = {
        public  = { instance_type               = "t3.medium"
                    ami                         = "ami-0baa9e2e64f3c00db",
                    subnet_id                   = module.vpc.subnet_public,
                    availability_zone           = module.vpc.availability_zone_public,
                    security_groups             = [module.vpc.security_group],
                    key_name                    = "markokey",
                    associate_public_ip_address = true}
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
            # service
            subnet_id               = module.vpc.subnet_public
            assign_public_ip        = true
        },
        redis = {
            # task
            cpu                     = 512
            memory                  = 2048
            container_definitions   = "resources/ecs-task-definitions/redis.json"
            # service
            subnet_id               = module.vpc.subnet_private
            assign_public_ip        = false
        }
    }

    security_groups     = [module.vpc.security_group]

    security_group_rules = {
        redis = {
            port = 6379
            cidr_blocks = [fileexists("my_ip.txt") ? "${chomp(file("my_ip.txt"))}/32" : "127.0.0.0/32"]
            description = "Redis port"
        }
    }
}


