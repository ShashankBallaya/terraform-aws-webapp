resource "aws_db_subnet_group" "main" {
  name = "webapp-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags = { Name = "webapp-db-subnet-group"}
}

resource "aws_db_instance" "main" {
  identifier= "webapp-rds"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot = true
  multi_az = false
  publicly_accessible = false 
  tags = { Name = "webapp-rds"}
}