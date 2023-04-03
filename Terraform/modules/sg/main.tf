# 3 SG needed: RDS(Allow MySQL 3306), ALB(Allow HTTP AND HTTPS), ASG(Allow HTTP and SSH)
// ALB SG
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${terraform.workspace}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_rules" {

  security_group_id = aws_security_group.alb-sg.id
  count             = length(var.SECURITY_GROUPS.ALB_SG.ingress)
  type              = "ingress"
  description       = var.SECURITY_GROUPS.ALB_SG.ingress[count.index].description
  from_port         = var.SECURITY_GROUPS.ALB_SG.ingress[count.index].from_port
  to_port           = var.SECURITY_GROUPS.ALB_SG.ingress[count.index].to_port
  protocol          = var.SECURITY_GROUPS.ALB_SG.ingress[count.index].protocol
  cidr_blocks       = flatten([var.SECURITY_GROUPS.ALB_SG.ingress[count.index].cidr_block])

}
resource "aws_security_group_rule" "alb_egress_rules" {
  count             = length(var.SECURITY_GROUPS.ALB_SG.egress)
  type              = "egress"
  from_port         = var.SECURITY_GROUPS.ALB_SG.egress[count.index].from_port
  to_port           = var.SECURITY_GROUPS.ALB_SG.egress[count.index].to_port
  protocol          = var.SECURITY_GROUPS.ALB_SG.egress[count.index].protocol
  cidr_blocks       = flatten([var.SECURITY_GROUPS.ALB_SG.egress[count.index].cidr_block])
  security_group_id = aws_security_group.alb-sg.id
}

// ASG WEB SG 
resource "aws_security_group" "asg-web-sg" {
  name        = "asg-web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${terraform.workspace}-asg-web-sg"

  }
}

resource "aws_security_group_rule" "asg_ingress_rules" {
  count                    = length(var.SECURITY_GROUPS.ASG_SG.ingress)
  type                     = "ingress"
  description              = var.SECURITY_GROUPS.ASG_SG.ingress[count.index].description
  from_port                = var.SECURITY_GROUPS.ASG_SG.ingress[count.index].from_port
  to_port                  = var.SECURITY_GROUPS.ASG_SG.ingress[count.index].to_port
  protocol                 = var.SECURITY_GROUPS.ASG_SG.ingress[count.index].protocol
  source_security_group_id = aws_security_group.alb-sg.id
  security_group_id        = aws_security_group.asg-web-sg.id
}
resource "aws_security_group_rule" "asg_egress_rules" {
  count             = length(var.SECURITY_GROUPS.ASG_SG.egress)
  type              = "egress"
  from_port         = var.SECURITY_GROUPS.ASG_SG.egress[count.index].from_port
  to_port           = var.SECURITY_GROUPS.ASG_SG.egress[count.index].to_port
  protocol          = var.SECURITY_GROUPS.ASG_SG.egress[count.index].protocol
  cidr_blocks       = flatten([var.SECURITY_GROUPS.ASG_SG.egress[count.index].cidr_block])
  security_group_id = aws_security_group.asg-web-sg.id
}



// RDS SG
resource "aws_security_group" "rds-web-sg" {
  name        = "rds-web-sg"
  description = "Allow MYSQL traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${terraform.workspace}-rds-sg"

  }
}

resource "aws_security_group_rule" "rds_ingress_rules" {
  count                    = length(var.SECURITY_GROUPS.RDS_SG.ingress)
  type                     = "ingress"
  description              = var.SECURITY_GROUPS.RDS_SG.ingress[count.index].description
  from_port                = var.SECURITY_GROUPS.RDS_SG.ingress[count.index].from_port
  to_port                  = var.SECURITY_GROUPS.RDS_SG.ingress[count.index].to_port
  protocol                 = var.SECURITY_GROUPS.RDS_SG.ingress[count.index].protocol
  security_group_id        = aws_security_group.rds-web-sg.id
  source_security_group_id = aws_security_group.asg-web-sg.id

}
resource "aws_security_group_rule" "rds_egress_rules" {
  count             = length(var.SECURITY_GROUPS.RDS_SG.egress)
  type              = "egress"
  from_port         = var.SECURITY_GROUPS.RDS_SG.egress[count.index].from_port
  to_port           = var.SECURITY_GROUPS.RDS_SG.egress[count.index].to_port
  protocol          = var.SECURITY_GROUPS.RDS_SG.egress[count.index].protocol
  cidr_blocks       = flatten([var.SECURITY_GROUPS.RDS_SG.egress[count.index].cidr_block])
  security_group_id = aws_security_group.rds-web-sg.id
}
