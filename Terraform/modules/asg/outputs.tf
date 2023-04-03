output "asg_output" {
  value = {
    aws_asg = aws_autoscaling_group.piyush-asg.*
  }
}