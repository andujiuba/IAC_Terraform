# Let's set up our could provider wih Terraform

provider "aws" {
    region = "eu-west-1"
}

# 1.  Create a VPC with CIDR block
# 2. Run terraform plan then terraform apply
# 3. Get VPC ID from AWS or from terraform logs

# Launch a VPC

resource "aws_vpc" "sre_akunma_vpc_tf" {
    cidr_block = "10.101.0.0/16"
    tags = {
        Name = var.name
    }
}

# Create Internet Gateway

resource "aws_internet_gateway" "sre_akunma_tf_ig" {
    vpc_id = var.vpc_id
    tags = {
        Name = "sre_akunma_tf_ig"
    }
}

# Create Subnet 

resource "aws_subnet" "sre_akunma_tf_sub" {
    vpc_id = var.vpc_id
    cidr_block = "10.101.1.0/24"
    tags = {
        Name = "sre_akunma_tf_sub"
    }
}

# Create a Blank Route Table

resource "aws_route_table" "sre_akunma_tf_rt" {
    vpc_id = var.vpc_id
    route = []
    tags = {
        Name = "sre_akunma_tf_rt"
    }
}

# Adding Routes - Internet Gateway

resource "aws_route" "r" {
    route_table_id = var.rt_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = var.ig_id
}

# Route Table Association
 
resource "aws_route_table_association" "pub" {
    subnet_id = var.aws_pub_subnet
    route_table_id = var.rt_id
}

# Security Groups

resource "aws_security_group" "app_group" {
    name = "sre_akunma_tf_sg"
    description = "Security group for app"
    vpc_id = var.vpc_id
    # Inbound rules
    ingress {
        description = "From my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["92.14.100.64/32"]
    }
    ingress {
        description = "Allow Port 3000"
        from_port = 3000
        to_port = 3000
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "Public Access"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    # Outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "sre_akunma_tf_sg"
    }
}

# Launching an EC2 instance using the app AMI and VPC.

# resource "aws_instance" "app_instance" {
#     ami = "ami-0c6d0dba698fb80cd"
#     instance_type = "t2.micro"
#     associate_public_ip_address = true
#     tags = {
#         Name = "sre_akunma_terraform_app"
#     }
# }
