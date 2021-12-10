module vpc {
    source              = "../vpc"
    project_name        = var.project_name
}

module sg {
    source              = "../sg"
    vpc_id              = module.vpc.vpc_id
    security_group_name = var.project_name

    security_group_rules = [
                            {
                            from_port = 0
                            to_port   = 0
                            protocol  = -1
                            self      = true
                            cidr_blocks = []
                            description = ""
                            }
    ]
}

resource "aws_dms_replication_subnet_group" "subnet" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "${lower(replace(var.project_name, " ", "-"))}-replication-subnet-group-tf"

  subnet_ids = module.vpc.subnet_public

  tags = {
    Name = var.project_name
  }
}

# Create a new replication instance
resource "aws_dms_replication_instance" "instance" {
    allocated_storage               = 20
    apply_immediately               = true
    auto_minor_version_upgrade      = true
    availability_zone               = module.vpc.availability_zone[0]
    engine_version                  = "3.4.6"
    # kms_key_arn                   = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    multi_az                        = false
    preferred_maintenance_window    = "sun:10:30-sun:14:30"
    publicly_accessible             = true
    replication_instance_class      = "dms.t2.micro"
    replication_instance_id         = "${replace(var.project_name, " ", "-")}-replication-instance-tf"
    replication_subnet_group_id     = aws_dms_replication_subnet_group.subnet.id
    vpc_security_group_ids          = [module.sg.security_group_id]

    tags = {
        Name = var.project_name
    }

#   depends_on = [
#     aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
#     aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
#     aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
#   ]
}

