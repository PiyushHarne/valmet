module "vpc" {
  source = "./modules/vpc"
  VPC    = var.VPC
}
module "sg" {
  source          = "./modules/sg"
  vpc_id          = module.vpc.vpc_output.vpc_id
  SECURITY_GROUPS = var.SECURITY_GROUPS
}
module "alb" {
  source        = "./modules/alb"
  vpc_id        = module.vpc.vpc_output.vpc_id
  subnet_public = module.vpc.vpc_output.public_subnets
  alb_sg        = module.sg.sg_output.alb_sg_id
  ALB           = var.ALB
}
module "asg" {
  source         = "./modules/asg"
  subnet_private = module.vpc.vpc_output.private_subnets
  asg_sg_id      = module.sg.sg_output.asg_sg_id
  alb_target     = module.alb.alb_output.alb_target
  ASG            = var.ASG
}
module "db" {
  source         = "./modules/db"
  db_sg          = module.sg.sg_output.rds_sg_id
  subnet_private = module.vpc.vpc_output.private_subnets
  DATABASES      = var.DATABASES
}
