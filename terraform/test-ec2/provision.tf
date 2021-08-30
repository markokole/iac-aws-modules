module "vpc" {
    source            = "../vpc"
    project_name      = "Test EC2"
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
                    associate_public_ip_address = true},
        private_1 = { instance_type               = "t3.medium"
                    ami                         = "ami-0baa9e2e64f3c00db",
                    subnet_id                   = module.vpc.subnet_private[0],
                    availability_zone           = module.vpc.availability_zone_private[0],
                    security_groups             = [module.vpc.security_group],
                    key_name                    = "markokey",
                    associate_public_ip_address = false},
        private_2 = { instance_type               = "t3.medium"
                    ami                         = "ami-0baa9e2e64f3c00db",
                    subnet_id                   = module.vpc.subnet_private[1],
                    availability_zone           = module.vpc.availability_zone_private[1],
                    security_groups             = [module.vpc.security_group],
                    key_name                    = "markokey",
                    associate_public_ip_address = false}
    }
}

output "module_ec2_outputs" {
  value = module.ec2
}