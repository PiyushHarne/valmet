VPC = {
  VPC_CIDR     = "10.0.0.0/16"
  CIDR_PUBLIC  = ["10.0.1.0/24", "10.0.2.0/24"]
  CIDR_PRIVATE = ["10.0.3.0/24", "10.0.4.0/24"]

}

DATABASES = {
  DB_NAME              = "wordpress"
  USERNAME             = "wordpress"
  IDENTIFIER           = "wordpress"
  ALLOCATED_STORAGE    = 10
  DB_ENGINE            = "mysql"
  DB_ENGINE_VERSION    = "8.0.28"
  DB_INSTANCE_CLASS    = "db.t3.micro"
  PARAMETER_GROUP_NAME = "default.mysql8.0"

}


SECURITY_GROUPS = {

  ALB_SG = {
    ingress = [
      {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = ["0.0.0.0/0"]

      },
      {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = ["0.0.0.0/0"]
      }
    ]
  }

  ASG_SG = {
    ingress = [
      {
        description = "HTTP access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"

      },
      {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
      }
    ]
    egress = [
      {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = ["0.0.0.0/0"]
      }
    ]

  }

  RDS_SG = {
    ingress = [
      {
        description = "MYSQL access"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = ["0.0.0.0/0"]
      }
    ]

  }

}

ASG = {
  DESIRED_CAPACITY     = 2
  MAX_SIZE             = 3
  MIN_SIZE             = 1
  KEY_NAME             = "piyushkp"
  INSTANCE_TYPE        = "t2.micro"
  INSTANCE_DESCRIPTION = "Amazon Linux 2 Kernel 5.10 AMI 2.0.20220419.0 x86_64 HVM gp2"
  EC2-AMI = {
    us-west-1 = "ami-09625adacc474a7b4"
    us-west-2 = "ami-02b92c281a4d3dc79"
    us-east-2 = "ami-0c6a6b0e75b2b6ce7"
    us-east-1 = "ami-0f9fc25dd2506cf6d"
  }

}

ALB = {
  ZONE_NAME          = "groveops.net"
  CERTIFICATE_DOMAIN = "*.groveops.net"
  NAME_RECORD        = "piyush.groveops.net"
  TYPE_RECORD        = "A"
  TARGET_GROUP = {
    NAME_TARGET     = "piyush-lb-tg"
    PORT_TARGET     = 80
    PROTOCOL_TARGET = "HTTP"
  }

  LOAD_BALANCER = {
    NAME               = "piyush-alb-tf"
    INTERNAL           = false
    LOAD_BALANCER_TYPE = "application"
  }
  // HTTPS LISTENERS PORT,PROTOCOL, SSL_POLICY REQUIRED. DEFAULT ACTION FORWARD
  HTTPS_LISTENERS = [
    {
      PORT        = 443
      PROTOCOL    = "HTTPS"
      SSL_POLICY  = "ELBSecurityPolicy-2016-08"
      ACTION_TYPE = "forward"
    },
    {
      PORT        = 446
      PROTOCOL    = "HTTPS"
      SSL_POLICY  = "ELBSecurityPolicy-2016-08"
      ACTION_TYPE = "redirect"
      REDIRECT = {
        PORT        = "448"
        PROTOCOL    = "HTTPS"
        STATUS_CODE = "HTTP_301"
      }
    }
  ]
  // HTTP LISTENERS FOR ALB
  HTTP_LISTENERS = [
    {
      PORT        = 80
      PROTOCOL    = "HTTP"
      ACTION_TYPE = "redirect"
      REDIRECT = {
        PORT        = "443"
        PROTOCOL    = "HTTPS"
        STATUS_CODE = "HTTP_301"
      }
    },
    {
      PORT        = 81
      PROTOCOL    = "HTTP"
      ACTION_TYPE = "fixed-response"
      FIXED_RESPONSE = {
        CONTENT_TYPE = "text/plain"
        MESSAGE_BODY = "Fixed message"
        STATUS_CODE  = "200"
      }
    },
    {
      PORT        = 83
      PROTOCOL    = "HTTP"
      ACTION_TYPE = "forward"
    }
  ]
}
