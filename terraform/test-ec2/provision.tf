module "vpc" {
    source            = "../vpc"
    project_name      = "Test EC2"

}

module "ec2" {
    source                      = "../ec2"
    project_name                = module.vpc.project_name
    instance_type               = "t3.medium"
    ami                         = "ami-0baa9e2e64f3c00db"  # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
    security_groups             = [module.vpc.security_group]
    subnet                      = module.vpc.subnet_public
    availability_zone           = module.vpc.availability_zone_public
    key_name                    = "markokey"
    associate_public_ip_address = true
}

output "module_ec2_outputs" {
  value = module.ec2
}