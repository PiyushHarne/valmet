output "vpc_output" {
  value = {
    vpc_id            = aws_vpc.main.id
    public_subnets    = aws_subnet.main-public.*
    private_subnets   = aws_subnet.main-private.*
    vpc_azs_available = local.total_az
  }
}