resource "aws_security_group" "alb" {
  name = "webapp-alb-sg"
  description = "ALB security group"
  vpc_id =  var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {Name = "webapp-alb-sg"}
}

resource "aws_security_group" "ec2" {
  name = "webapp-ec2-sg"
  description = "EC2 security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # possible error
    cidr_blocks = ["${var.your_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "webapp-ec2-sg"}
}

resource "aws_security_group" "rds" {
  name = "webap-rds-sg"
  description = "RDS security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "webapp-rds-sg"}
}