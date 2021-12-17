resource "aws_security_group" "sg" {
    name        = var.security_group_name
    vpc_id      = var.vpc_id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    dynamic ingress {
        for_each = var.security_group_rules
        content {
            from_port   = ingress.value["from_port"]
            to_port     = ingress.value["to_port"]
            protocol    = ingress.value["protocol"]
            self        = ingress.value["self"]
            cidr_blocks = ingress.value["cidr_blocks"]
            description = ingress.value["description"]
        }
    }

    tags = {
        Name = var.security_group_name
    }
}