provider "aws" {
    region = "eu-west-1"
}

# Get all availability zones from the region
data "aws_availability_zones" "available" {
    state = "available"
}

# Create the VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_hostnames = true

    tags = {
        Name    = var.project_name
        source  = "Terraform"
    }
}

# Create public subnet
resource "aws_subnet" "public" {
    count               = length(local.public_cidr_blocks)
    vpc_id              = aws_vpc.vpc.id
    cidr_block          = local.public_cidr_blocks[count.index]
    availability_zone   = local.availability_zone_names[count.index]

    tags = {
        Name = "Public subnet ${count.index}"
    }
}

# Create private subnets
resource "aws_subnet" "private" {
    count               = length(local.private_cidr_blocks)
    vpc_id              = aws_vpc.vpc.id
    cidr_block          = local.private_cidr_blocks[count.index]
    availability_zone   = local.availability_zone_names[count.index]

    tags = {
        Name = "Private subnet ${count.index}"
    }
}

# Create internet gateway for communication with the internet
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.project_name
    }
}

# Create route table where all internet bound traffic is sent to internet gateway
resource "aws_route_table" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id

    route = [
        {
        cidr_block                 = "0.0.0.0/0"
        gateway_id                 = aws_internet_gateway.igw.id
        carrier_gateway_id         = ""
        destination_prefix_list_id = ""
        egress_only_gateway_id     = ""
        instance_id                = ""
        ipv6_cidr_block            = ""
        local_gateway_id           = ""
        nat_gateway_id             = ""
        network_interface_id       = ""
        transit_gateway_id         = ""
        vpc_endpoint_id            = ""
        vpc_peering_connection_id  = ""
        }
    ]

    tags = {
        Name = var.project_name
    }
}

# Associate the Internet Gateway route table with the public subnet
resource "aws_route_table_association" "subnet_public" {
    count           = length(local.public_subnet_ids)
    subnet_id       = local.public_subnet_ids[count.index]
    route_table_id  = aws_route_table.internet_gateway.id
}

# Create an Elastic IP
resource "aws_eip" "ip" {
    count = length(local.public_subnet_ids)
    tags = {
        Name = "IP for NAT Gateway ${count.index}"
    }
}

# Create NAT gateway in public subnet to allow instances in private subnet to send traffic to the internet
# but the internet cannot connect to the instances
resource "aws_nat_gateway" "gateway" {
    count               = length(aws_eip.ip)
    allocation_id       = aws_eip.ip[count.index].allocation_id
    subnet_id           = local.public_subnet_ids[count.index]
    connectivity_type   = "public"

    tags = {
        Name = "Project ${var.project_name} - Gateway ${count.index}"
    }

    depends_on          = [aws_internet_gateway.igw]
}

# Create route table where all internet bound traffic is sent to nat gateway
resource "aws_route_table" "nat_gateway" {
    count   = length(aws_nat_gateway.gateway)
    vpc_id  = aws_vpc.vpc.id

    route   = [
        {
        cidr_block                 = "0.0.0.0/0"
        gateway_id                 = aws_nat_gateway.gateway[count.index].id
        carrier_gateway_id         = ""
        destination_prefix_list_id = ""
        egress_only_gateway_id     = ""
        instance_id                = ""
        ipv6_cidr_block            = ""
        local_gateway_id           = ""
        nat_gateway_id             = ""
        network_interface_id       = ""
        transit_gateway_id         = ""
        vpc_endpoint_id            = ""
        vpc_peering_connection_id  = ""
        }
    ]

    tags    = {
        Name = "NAT Gateway ${count.index}"
    }

    # bug: kept changing this resource for some reason
    lifecycle {
        ignore_changes = [route]
    }
}

# # Associate the nat gateway route table with the private subnet
resource "aws_route_table_association" "subnet_private_nat_gateway" {
    count           = length(local.private_subnet_ids)
    subnet_id       = local.private_subnet_ids[count.index]
    route_table_id  = aws_route_table.nat_gateway[count.index].id
}
