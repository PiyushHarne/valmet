// Declare the data source for AZ
data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  total_az             = length(data.aws_availability_zones.available.names)
  total_public_subnet  = length(var.VPC.CIDR_PUBLIC)
  total_private_subnet = length(var.VPC.CIDR_PRIVATE)
}
// VPC
resource "aws_vpc" "main" {
  cidr_block       = var.VPC.VPC_CIDR
  instance_tenancy = "default"
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}
// PUBLIC SUBNETS
resource "aws_subnet" "main-public" {
  vpc_id                  = aws_vpc.main.id
  count                   = local.total_public_subnet
  cidr_block              = var.VPC.CIDR_PUBLIC[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index % local.total_az]

  tags = {
    Name = "main-public-${count.index + 1}"
  }
}

// PRIVATE SUBNETS
resource "aws_subnet" "main-private" {
  vpc_id                  = aws_vpc.main.id
  count                   = local.total_private_subnet
  cidr_block              = var.VPC.CIDR_PRIVATE[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index % local.total_az]

  tags = {
    Name = "main-private-${count.index + 1}"
  }
}

// INTERNET GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-igw"
  }
}
//Elastic IP for NAT 
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}
// NAT 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.main-public.0.id
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name = "${terraform.workspace}-nat"
  }
}

// Route Table for Public 
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${terraform.workspace}-public-route"
  }
}

// Route Table for Private 
resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${terraform.workspace}-private-route"
  }
}


// Main Public route table associations
resource "aws_route_table_association" "main-public" {
  count          = length(var.VPC.CIDR_PUBLIC)
  subnet_id      = aws_subnet.main-public.*.id[count.index]
  route_table_id = aws_route_table.main-public.id
}

// Main Private route table associations
resource "aws_route_table_association" "main-private" {
  count          = length(var.VPC.CIDR_PRIVATE)
  subnet_id      = aws_subnet.main-private.*.id[count.index]
  route_table_id = aws_route_table.main-private.id
}
