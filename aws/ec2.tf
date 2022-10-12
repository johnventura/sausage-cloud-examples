resource "aws_launch_template" "tracker_template" {
  name_prefix          = "tracker"
  image_id             = "ami-052efd3df9dad4825" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (AMD64)
  instance_type        = "t2.micro"              # cheap instance type. we chose money over performance
  key_name             = aws_key_pair.admin_key.id
  user_data            = base64encode(local.cloudinit_configure_tracker)
  security_group_names = [aws_security_group.allow_ssh_home.name]
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.tracker_instance_profile.name
  }
}

resource "aws_autoscaling_group" "tracker_asg" {
  availability_zones        = ["us-east-1b"]
  desired_capacity          = 1     # we prefer to only have 1 
  max_size                  = 1     # usually more than one instance running at once, but we only want one
  min_size                  = 1     # at least 1 host
  health_check_grace_period = 300   # grace period needed to avoid crash loop during initial boot
  health_check_type         = "EC2" # other option is "ELB", but this is not a load balancer

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.tracker_template.id
      }
    }
  }
  tag {
    key                 = "Name"
    value               = "tracker" # This is the name that will show up in the GUI
    propagate_at_launch = true
  }
}

locals {
  # a python script will interrpret this YAML file.
  # You might have to install the "cloud-init" package in your base image.
  # first line of a cloud-init script has to be "#cloud-config"
  # see https://cloudinit.readthedocs.io/en/latest/ for the documentation
  cloudinit_configure_tracker = <<EOT
#cloud-config
write_files:
  - path: /etc/description
    permissions: 0644
    content: |
      This file exists to demonstrate cloud-init.

bootcmd:
  - /bin/touch /etc/created_at_boot

runcmd:
  - /bin/touch /etc/created_after_boot

EOT
}

resource "aws_security_group" "allow_ssh_home" {
  name        = "allow_ssh_home"
  description = "Allow SSH inbound traffic"
  # vpc_id      = "vpc-01234567" # your VPC goes here, if not using default
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH from Home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["9.9.9.9/32"] # list of IPs/networks that are allowed access
  }

  #  egress {
  #    from_port        = 0
  #    to_port          = 0
  #    protocol         = "-1"
  #    cidr_blocks      = ["0.0.0.0/0"] # might be a good idea to limit this
  #    ipv6_cidr_blocks = ["::/0"]
  #  }

  tags = {
    Name = "ssh_home"
  }
}
