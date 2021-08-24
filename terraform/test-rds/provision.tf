module "vpc" {
    source              = "../vpc"
    project_name        = "Test RDS Module"
    no_private_subnets  = 2
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

module "rds" {
    source          = "../rds"
    project_name    = module.vpc.project_name
    username        = "foo"
    password        = "foobarbaz"
    subnet_ids      = module.vpc.subnet_private
    security_groups = [module.vpc.security_group]

    security_group_rules = {
        mysql = {
            port = 3306
            cidr_blocks = [fileexists("my_ip.txt") ? "${chomp(file("my_ip.txt"))}/32" : "127.0.0.0/32"]
            description = "Redis port"
        }
    }
}