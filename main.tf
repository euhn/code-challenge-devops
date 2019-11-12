# This deploys a simple web server in an ASG with an ELB

# Require a specific terraform version or higher
terraform {
    required_version = ">=0.12"
}

provider "aws" {
  region = var.region
}

# Get the list of all AZs in the current account/region
data "aws_availability_zones" "all" {}

# Get the most recent ubuntu server ami
data "aws_ami" "latest_ubuntu" {
    most_recent = true
    owners = ["099720109477"] # Canonical

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# ---------------------------------------------------
# Create the Auto Scaling Group
# ---------------------------------------------------

resource "aws_autoscaling_group" "asg" {
    launch_configuration = aws_launch_configuration.launch_config.id
    availability_zones = data.aws_availability_zones.all.names

    min_size = var.min_size
    max_size = var.max_size

    load_balancers = [aws_elb.elb.name]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = var.cluster_name
        propagate_at_launch = true
    }
}

# -----------------------------------------------------------------
# Create the Launch Configuration defining each EC2 in the ASG
# -----------------------------------------------------------------

resource "aws_launch_configuration" "launch_config" {
    image_id = "${data.aws_ami.latest_ubuntu.id}"
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]

    user_data = "${file("bootstrap.sh")}"

    lifecycle {
        create_before_destroy = true
    }
}

# -----------------------------------------------------------------
# Create the Security Group applied to each EC2
# -----------------------------------------------------------------

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance-sg"

    # Inbound HTTP from anywhere
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow outbound
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# -----------------------------------------------------------------
# Create the ELB to route traffic across the ASG
# -----------------------------------------------------------------

resource "aws_elb" "elb" {
    name = "${var.cluster_name}-elb"
    security_groups = [aws_security_group.elb.id]
    availability_zones = data.aws_availability_zones.all.names

    health_check {
        target = "HTTP:${var.server_port}/"
        interval = 30
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    # This adds a listener for incoming HTTP requests.
    listener {
        lb_port = var.elb_port
        lb_protocol = "http"
        instance_port = var.server_port
        instance_protocol = "http"
    }
}

# -----------------------------------------------------------------
# Create the Security Group that controls traffic for the ELB
# -----------------------------------------------------------------

resource "aws_security_group" "elb" {
    name = "${var.cluster_name}-elb-sg"

    # Allow outbound
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Inbound HTTP from anywhere
    ingress {
        from_port = var.elb_port
        to_port = var.elb_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
