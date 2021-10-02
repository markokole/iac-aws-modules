module "vpc" {
    source            = "../vpc"
    project_name      = "Test EC2"
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

locals {
    user_data_spark = <<EOF
#!/bin/bash
yum install wget -y
# /usr/bin/wget https://apache.uib.no/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz -P /home/ec2-user
# /usr/bin/tar zxvf /home/ec2-user/spark-3.1.2-bin-hadoop3.2.tgz -C /home/ec2-user
# yum -y install java-11-openjdk-devel
# /bin/echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.12.0.7-0.el8_4.x86_64" >> /home/ec2-user/.bashrc
# source ~/.bashrc
# /home/ec2-user/spark-3.1.2-bin-hadoop3.2/bin/run-example SparkPi 10 > /home/ec2-user/sparkpi.out
EOF
}

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
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
                    user_data                   = local.user_data_spark
                    }
        # private_1 = { instance_type               = "t3.medium"
        #             ami                         = "ami-0baa9e2e64f3c00db",
        #             subnet_id                   = module.vpc.subnet_private[0],
        #             availability_zone           = module.vpc.availability_zone_private[0],
        #             security_groups             = [module.vpc.security_group],
        #             key_name                    = "markokey",
        #             associate_public_ip_address = false}
        # private_2 = { instance_type               = "t3.medium"
        #             ami                         = "ami-0baa9e2e64f3c00db",
        #             subnet_id                   = module.vpc.subnet_private[1],
        #             availability_zone           = module.vpc.availability_zone_private[1],
        #             security_groups             = [module.vpc.security_group],
        #             key_name                    = "markokey",
        #             associate_public_ip_address = false}
    }
}

output "module_ec2_outputs" {
  value = module.ec2
}