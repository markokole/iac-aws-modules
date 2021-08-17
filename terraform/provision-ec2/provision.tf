module "vpc" {
    source            = "../vpc"
}

module "ec2" {
    source                      = "../ec2"
    security_groups             = [module.vpc.security_group]
    subnet_private              = module.vpc.subnet_private
    subnet_public               = module.vpc.subnet_public
    availability_zone_private   = module.vpc.availability_zone_private
    availability_zone_public    = module.vpc.availability_zone_public
}

output "module_ec2_outputs" {
  value = module.ec2
}