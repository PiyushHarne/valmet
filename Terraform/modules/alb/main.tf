# Find your hosted zone
data "aws_route53_zone" "myzone" {
  name         = var.ALB.ZONE_NAME
  private_zone = false
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = var.ALB.CERTIFICATE_DOMAIN
  statuses = ["ISSUED"]
}
# Create record in your zone
resource "aws_route53_record" "piyush" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = var.ALB.NAME_RECORD
  type    = var.ALB.TYPE_RECORD
  alias {
    name                   = aws_lb.piyush-alb.dns_name
    zone_id                = aws_lb.piyush-alb.zone_id
    evaluate_target_health = true
  }
}

# Create Target Group
resource "aws_lb_target_group" "piyush-target" {
  name     = var.ALB.TARGET_GROUP.NAME_TARGET
  port     = var.ALB.TARGET_GROUP.PORT_TARGET
  protocol = var.ALB.TARGET_GROUP.PROTOCOL_TARGET
  vpc_id   = var.vpc_id
}
# Create ALB
resource "aws_lb" "piyush-alb" {
  name               = var.ALB.LOAD_BALANCER.NAME
  internal           = var.ALB.LOAD_BALANCER.INTERNAL
  load_balancer_type = var.ALB.LOAD_BALANCER.LOAD_BALANCER_TYPE
  security_groups    = [var.alb_sg]
  subnets            = [for subnet in var.subnet_public : subnet.id]

  tags = {
    Name = "${terraform.workspace}-alb"
  }
}
# HTTP LISTENER FOR ALB
resource "aws_lb_listener" "piyush-alb-http" {
  count             = length(var.ALB.HTTP_LISTENERS)
  load_balancer_arn = aws_lb.piyush-alb.arn
  port              = var.ALB.HTTP_LISTENERS[count.index]["PORT"]
  protocol          = var.ALB.HTTP_LISTENERS[count.index]["PROTOCOL"]

  dynamic "default_action" {
    for_each = [var.ALB.HTTP_LISTENERS[count.index]]
    content {
      type             = lookup(default_action.value, "ACTION_TYPE", "forward")
      target_group_arn = aws_lb_target_group.piyush-target.arn
      dynamic "redirect" {
        for_each = length(keys(lookup(default_action.value, "REDIRECT", {}))) == 0 ? [] : [lookup(default_action.value, "REDIRECT", {})]
        content {
          port        = lookup(redirect.value, "PORT", null)
          protocol    = lookup(redirect.value, "PROTOCOL", null)
          status_code = redirect.value.STATUS_CODE
        }
      }
      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "FIXED_RESPONSE", {}))) == 0 ? [] : [lookup(default_action.value, "FIXED_RESPONSE", {})]
        content {
          content_type = fixed_response.value.CONTENT_TYPE
          message_body = lookup(fixed_response.value, "MESSAGE_BODY", null)
          status_code  = lookup(fixed_response.value, "STATUS_CODE", null)
        }
      }
    }
  }
}
// HTTPS LISTENERS FOR ALB
resource "aws_lb_listener" "piyush-alb-https" {
  count             = length(var.ALB.HTTPS_LISTENERS)
  load_balancer_arn = aws_lb.piyush-alb.arn
  port              = var.ALB.HTTPS_LISTENERS[count.index]["PORT"]
  protocol          = var.ALB.HTTPS_LISTENERS[count.index]["PROTOCOL"]
  ssl_policy        = var.ALB.HTTPS_LISTENERS[count.index]["SSL_POLICY"]
  certificate_arn   = data.aws_acm_certificate.issued.arn

  dynamic "default_action" {
    for_each = [var.ALB.HTTPS_LISTENERS[count.index]]
    content {
      type             = lookup(default_action.value, "ACTION_TYPE", "forward")
      target_group_arn = aws_lb_target_group.piyush-target.arn
      dynamic "redirect" {
        for_each = length(keys(lookup(default_action.value, "REDIRECT", {}))) == 0 ? [] : [lookup(default_action.value, "REDIRECT", {})]
        content {
          port        = lookup(redirect.value, "PORT", null)
          protocol    = lookup(redirect.value, "PROTOCOL", null)
          status_code = redirect.value.STATUS_CODE
        }
      }
      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "FIXED_RESPONSE", {}))) == 0 ? [] : [lookup(default_action.value, "FIXED_RESPONSE", {})]
        content {
          content_type = fixed_response.value.CONTENT_TYPE
          message_body = lookup(fixed_response.value, "MESSAGE_BODY", null)
          status_code  = lookup(fixed_response.value, "STATUS_CODE", null)
        }
      }
    }
  }
}