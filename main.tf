terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "shashank-tf-state-webapp"
    key            = "webapp/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "shashank-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
  aws_region           = var.aws_region
}

module "sg" {
  source  = "./modules/sg"
  vpc_id  = module.vpc.vpc_id
  your_ip = var.your_ip
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

module "asg" {
  source             = "./modules/asg"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.sg.ec2_sg_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
}

module "rds" {
  source        = "./modules/rds"
  vpc_id        = module.vpc.vpc_id
  db_subnet_ids = module.vpc.db_subnet_ids
  rds_sg_id     = module.sg.rds_sg_id
  db_username   = var.db_username
  db_password   = var.db_password
  db_name       = var.db_name
}