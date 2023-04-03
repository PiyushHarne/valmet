output "sg_output" {
  value = {
    alb_sg_id = aws_security_group.alb-sg.id
    asg_sg_id = aws_security_group.asg-web-sg.id
    rds_sg_id = aws_security_group.rds-web-sg.id
  }
}