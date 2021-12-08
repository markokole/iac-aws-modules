provider "aws" {
    region = "eu-north-1"
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
    for_each = toset(slice(local.cidr_blocks, 1, var.no_public_subnets + 1))
    vpc_id              = aws_vpc.vpc.id
    cidr_block          = each.key
    availability_zone   = data.aws_availability_zones.available.names[index(slice(local.cidr_blocks, 1, var.no_public_subnets + 1), each.key)]

    tags = {
        Name = "Public subnet ${index(slice(local.cidr_blocks, 1, var.no_public_subnets + 1), each.key)}"
    }
}

# Create private subnets
resource "aws_subnet" "private" {
    for_each = toset(slice(local.cidr_blocks, 1, var.no_private_subnets + 1))
    vpc_id              = aws_vpc.vpc.id
    cidr_block          = each.key
    availability_zone   = data.aws_availability_zones.available.names[index(slice(local.cidr_blocks, 1, var.no_private_subnets + 1), each.key)]

    tags = {
        Name = "Private subnet ${index(slice(local.cidr_blocks, 1, var.no_private_subnets + 1), each.key)}"
    }
}

# Create internet gateway for communication with the internet
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "IGW for VPC basics"
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
        Name = "Internet Gateway"
    }
}

# Associate the Internet Gateway route table with the public subnet
resource "aws_route_table_association" "subnet_public" {
    subnet_id       =  aws_subnet.public.id
    route_table_id  = aws_route_table.internet_gateway.id
}

# Create an Elastic IP
resource "aws_eip" "ip" {
    tags = {
        Name = "IP for NAT Gateway"
    }
}

# Create NAT gateway in public subnet to allow instances in private subnet to send traffic to the internet
# but the internet cannot connect to the instances
resource "aws_nat_gateway" "gateway" {
    allocation_id       = aws_eip.ip.id
    subnet_id           = aws_subnet.public.id
    connectivity_type   = "public"

    depends_on          = [aws_internet_gateway.igw]
}

# Create route table where all internet bound traffic is sent to nat gateway
resource "aws_route_table" "nat_gateway" {
    vpc_id = aws_vpc.vpc.id

    route = [
        {
        cidr_block                 = "0.0.0.0/0"
        gateway_id                 = aws_nat_gateway.gateway.id
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
        Name = "NAT Gateway"
    }

    # bug: kept changing this resource for some reason
    lifecycle {
        ignore_changes = [route]
    }
}

# Associate the nat gateway route table with the private subnet
resource "aws_route_table_association" "subnet_private_nat_gateway" {
    for_each = aws_subnet.private
    subnet_id =  each.value.id
    route_table_id = aws_route_table.nat_gateway.id
}
