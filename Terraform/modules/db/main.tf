resource "aws_db_subnet_group" "main" {
  name        = "piyushprivate"
  description = "Private subnets for RDS instance"
  subnet_ids  = [for subnet in var.subnet_private : subnet.id]

  tags = {
    Name = "PIYUSH subnet group"
  }
}
// Create random password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
// Create Secret manager secret
resource "aws_secretsmanager_secret" "rdscred" {
  name = "piyushrds"
}

resource "aws_db_instance" "wordpress" {
  allocated_storage      = var.DATABASES.ALLOCATED_STORAGE
  engine                 = var.DATABASES.DB_ENGINE
  engine_version         = var.DATABASES.DB_ENGINE_VERSION
  instance_class         = var.DATABASES.DB_INSTANCE_CLASS
  db_name                = var.DATABASES.DB_NAME
  username               = var.DATABASES.USERNAME
  password               = random_password.password.result
  identifier             = var.DATABASES.IDENTIFIER
  parameter_group_name   = var.DATABASES.PARAMETER_GROUP_NAME
  vpc_security_group_ids = [var.db_sg]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
}
// Create secret string for 
locals {
  cred = {
    dbname   = aws_db_instance.wordpress.db_name
    username = aws_db_instance.wordpress.username
    password = aws_db_instance.wordpress.password
    host     = aws_db_instance.wordpress.endpoint
    port     = aws_db_instance.wordpress.port
    engine   = aws_db_instance.wordpress.engine
  }
}
// Store secrets of db
resource "aws_secretsmanager_secret_version" "rdscred" {
  secret_id     = aws_secretsmanager_secret.rdscred.id
  secret_string = jsonencode(local.cred)
}
