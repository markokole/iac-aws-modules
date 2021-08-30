module "vpc" {
    source              = "../vpc"
    project_name        = "Test Redshift Module"
    #no_private_subnets  = 1
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

module "redshift" {
    source                      = "../redshift"
    cluster_identifier          = module.vpc.project_name
    master_username             = "foo"
    master_password             = "Foobarbaz1"
    cluster_type                = "single-node"
    subnet_ids                  = module.vpc.subnet_private
    vpc_security_group_ids      = [module.vpc.security_group]
    availability_zone           = module.vpc.availability_zone_private[0]

    security_group_rules = {
        redshift = {
            port = 5439
            cidr_blocks = ["${module.vpc.my_ip}/32"]
            description = "Redshift port"
        }
    }
}