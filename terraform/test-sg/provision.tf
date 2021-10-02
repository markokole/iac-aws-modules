module vpc {
    source              = "../vpc"
    project_name        = "Test Security Group"
    no_private_subnets  = 1
}

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module sg {
    source              = "../sg"
    vpc_id              = module.vpc.vpc_id
    security_group_name = "Test SG module"

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