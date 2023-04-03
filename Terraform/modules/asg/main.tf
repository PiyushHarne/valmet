// Declare the data source for IAM Roles
data "aws_iam_role" "rds" {
  name = "piyush-rdskeys-access"
}
data "aws_region" "current" {}

// Create Launch Template
resource "aws_launch_template" "piyush-tf-lt" {
  name        = "${terraform.workspace}-tf-lt"
  description = "my launch template"

  image_id      = var.ASG.EC2-AMI["${data.aws_region.current.name}"]
  instance_type = var.ASG.INSTANCE_TYPE
  // Attach IAM role to access RDS credentials used in bootstrap script
  iam_instance_profile {
    name = data.aws_iam_role.rds.name
  }
  key_name = var.ASG.KEY_NAME

  vpc_security_group_ids = [var.asg_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${terraform.workspace}-web"

    }
  }
  user_data = filebase64("${path.module}/scripts/web.sh")
}
// Create ASG 
resource "aws_autoscaling_group" "shanwar-asg" {
  name                = "${terraform.workspace}-asg"
  vpc_zone_identifier = [for subnet in var.subnet_private : subnet.id]
  desired_capacity    = var.ASG.DESIRED_CAPACITY
  max_size            = var.ASG.MAX_SIZE
  min_size            = var.ASG.MIN_SIZE
  target_group_arns   = [var.alb_target]
  launch_template {
    id      = aws_launch_template.piyush-tf-lt.id
    version = "$Latest"
  }
}
