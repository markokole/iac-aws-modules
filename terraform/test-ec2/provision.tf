module "vpc" {
    source            = "../vpc"
    project_name      = "Test EC2"

}

module "ec2" {
    source                      = "../ec2"
    project_name        = module.vpc.project_name
    security_groups     = [module.vpc.security_group]
    subnet              = module.vpc.subnet_public
    availability_zone   = module.vpc.availability_zone_public
}

output "module_ec2_outputs" {
  value = module.ec2
}