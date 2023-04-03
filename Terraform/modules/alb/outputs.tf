output "alb_output" {
  value = {
    alb_target = aws_lb_target_group.piyush-target.arn
  }
}