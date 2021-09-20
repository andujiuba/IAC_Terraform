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

# Create a Public Subnet 

resource "aws_subnet" "sre_akunma_tf_sub" {
    vpc_id = var.vpc_id
    cidr_block = "10.101.1.0/24"
    availability_zone = "eu-west-1a"
     map_public_ip_on_launch = "true"
    tags = {
        Name = "sre_akunma_tf_sub"
    }
}

# Create a Private Subnet

resource "aws_subnet" "sre_akunma_priv_tf_sub" {
    vpc_id = var.vpc_id
    cidr_block = "10.101.2.0/24"
    # For load balancer
    availability_zone = "eu-west-1b"
    tags = {
        Name = "sre_akunma_priv_tf_sub"
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

resource "aws_route_table_association" "priv" {
    subnet_id = var.aws_priv_subnet
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

# DB Security Group

resource "aws_security_group" "db_group"  {
    name = "sre_akunma_db_tf_sg"
    description = "Security group for db"
    vpc_id = var.vpc_id
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "27017"
        to_port = "27017"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # allow all
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "sre_akunma_db_tf_sg"
  }
}

# Launching an EC2 instance using the db AMI and VPC.

resource "aws_instance" "db_instance" {
    ami = var.db_ami_id
    subnet_id =  var.aws_priv_subnet
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
       Name = "sre_akunma_tf_db"
    }
    vpc_security_group_ids = [var.sg_priv_id]
    key_name = var.aws_key_name
    connection {
		type = "ssh"
		user = "ubuntu"
		private_key = var.aws_key_path
		host = "${self.associate_public_ip_address}"
	} 
}

# Launching an EC2 instance using the app AMI and VPC.

resource "aws_instance" "app_instance" {
    ami = var.webapp_ami_id
    subnet_id = var.aws_pub_subnet
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
        Name = "sre_akunma_tf_app"
    }
    vpc_security_group_ids = [var.sg_pub_id]
    key_name = var.aws_key_name
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = var.aws_key_path
        host = "${self.associate_public_ip_address}"
    }
}


#Load Balancing, Auto Scaling

# Create a launch configuration

resource "aws_launch_configuration" "app_launch_configuration" {
    name = "sre_akunma_tf_lc"
    image_id = var.webapp_ami_id
    instance_type = "t2.micro"
}

# Create an application load balancer

resource "aws_lb" "sre_akunma_tf_lb" {
    name = "sre-akunma-tf-lb"
    internal = false
    load_balancer_type = "application"
    subnets = [
        var.aws_pub_subnet,
        var.aws_priv_subnet
    ]

    tags = {
        Name = "sre_akunma_tf_lb"
    }
}

# Create an instance target group

resource "aws_lb_target_group" "sre_akunma_tg" {
    name = "sre-akunma-tf-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

    tags = {
        Name = "sre_akunma_tf_tg"
    }
}

# Create a listener

resource "aws_lb_listener" "sre_akunma_listener" {
    load_balancer_arn = var.lb_arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = var.tg_arn
    }
}

resource "aws_lb_target_group_attachment" "sre_akunma_tg_att" {
    target_group_arn = var.tg_arn
    target_id = var.target_id
    port = 80
}

# Create an Auto Scaling group (from launch configuration)

resource "aws_autoscaling_group" "sre_akunma_ASG_tf" {
    name = "sre_akunma_ASG_tf"

    min_size = 1
    desired_capacity = 1
    max_size = 3

    vpc_zone_identifier = [
        var.aws_pub_subnet,
        var.aws_priv_subnet
    ]

    launch_configuration = var.launch_config_name
}

resource "aws_autoscaling_policy" "akunma_AS_policy" {
    name = "sre_akunma_AS_policy"
    policy_type = "TargetTrackingScaling"
    estimated_instance_warmup = 100
    autoscaling_group_name = var.AS_name

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
    }
}