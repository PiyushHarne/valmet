output "db_output" {
  value = {
    aws_db = aws_db_instance.wordpress.db_name
  }
}