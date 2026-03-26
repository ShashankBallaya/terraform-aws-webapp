data "aws_ami" "amazon_linux_2" {
    most_recent = true 
    owners = ["amazon"]

    filter {
      name = "name"
      values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
    }
}

resource "aws_launch_template" "main"{
  name_prefix = "webapp-lt-"
  image_id = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.ec2_sg_id]
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  yum update -y
  yum install httpd -y
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Project 2 - Terraform 3-Tier HA</h1><p>Instance: $(hostname -f)</p>" > /var/www/html/index.html
  EOF
  )

  tags = { Name = "webapp-lt"}
}

resource "aws_autoscaling_group" "main" {
    name = "webapp-asg"
    desired_capacity = 2 
    min_size = 1
    max_size = 4
    vpc_zone_identifier = var.private_subnet_ids
    target_group_arns = [var.target_group_arn]
    health_check_type = "ELB"
    health_check_grace_period = 60

    launch_template {
        id = aws_launch_template.main.id 
        version = "$Latest"
    }

    tag {
        key = "Name"
        value = "webapp-asg-instance"
        propagate_at_launch = true
    }
}

