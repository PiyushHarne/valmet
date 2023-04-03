output "output_root_data" {
  value = {
    vpc_id            = module.vpc.vpc_output.vpc_id
    public_subnet     = module.vpc.vpc_output.public_subnets.*
    private_subnet    = module.vpc.vpc_output.private_subnets.*
    vpc_azs_available = module.vpc.vpc_output.vpc_azs_available
    alb_sg_id         = module.sg.sg_output.alb_sg_id
    asg_sg_id         = module.sg.sg_output.asg_sg_id
    rds_sg_id         = module.sg.sg_output.rds_sg_id
    alb_target        = module.alb.alb_output.alb_target
    aws_asg           = module.asg.asg_output.aws_asg.*
    aws_db            = module.db.db_output.aws_db
  }
}