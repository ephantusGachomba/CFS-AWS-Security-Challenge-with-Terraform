#create vpc
resource "aws_vpc" "cloudforce_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "cloudforce_vpc"
  }
}


#creating public subnet A
resource "aws_subnet" "cloudforce_publicA" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "cloudforce_publicA"
  }
}

#creating public subnet B
resource "aws_subnet" "cloudforce_publicB" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "cloudforce_publicB"
  }
}

#creating private subnet A (Web server A)
resource "aws_subnet" "cloudforce_privateA" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "cloudforce_privateA"
  }
}

#creating private subnet B (Web server B)
resource "aws_subnet" "cloudforce_privateB" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "cloudforce_privateB"
  }
}

#creating private subnet C (App server)
resource "aws_subnet" "cloudforce_privateC" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "cloudforce_privateC"
  }
}
#creating private subnet D (App server)
resource "aws_subnet" "cloudforce_privateD" {
  vpc_id            = aws_vpc.cloudforce_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "cloudforce_privateD"
  }
}

#creating an internet gateway
resource "aws_internet_gateway" "cloudforce_igw" {
  vpc_id = aws_vpc.cloudforce_vpc.id

  tags = {
    "Name" = "cloudforce_igw"
  }
}

#creating a route table
resource "aws_route_table" "cloudforce_rtb_public" {
  vpc_id = aws_vpc.cloudforce_vpc.id

  tags = {
    "Name" = "cloudforce_rtb_public"
  }
}

#creating a route
resource "aws_route" "cloudforce_rt" {
  route_table_id         = aws_route_table.cloudforce_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudforce_igw.id
}

#associate route table with public subnets A & B
resource "aws_route_table_association" "rt_ass_public" {
  count          = 2
  subnet_id      = element([aws_subnet.cloudforce_publicA.id, aws_subnet.cloudforce_publicB.id], count.index)
  route_table_id = aws_route_table.cloudforce_rtb_public.id
}


#create an elastic IP
resource "aws_eip" "cloud_natgateway_eip" {
  domain = "vpc" # Ensures the EIP is allocated in the VPC context
}

#create a NAT gateway in public subnet A
resource "aws_nat_gateway" "cloudNAT" {
  subnet_id = aws_subnet.cloudforce_publicA.id

  #ensures that the EIP is created first
  depends_on = [aws_eip.cloud_natgateway_eip]

  #allocate Elastic IP to the NAT Gateway
  allocation_id = aws_eip.cloud_natgateway_eip.id

  tags = {
    "Name" = "NAT gateway 1"
  }
}


#create a Route Table for the NAT Gateway
resource "aws_route_table" "NAT_Gateway_RT" {
  depends_on = [aws_nat_gateway.cloudNAT]

  vpc_id = aws_vpc.cloudforce_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cloudNAT.id
  }

  tags = {
    "Name" = "Route Table for NAT Gateway"
  }
}

#Associating route table for NAT gateway to private web subnet A,B (Web server) & 
#private app subnet C,D (app server)
resource "aws_route_table_association" "rt_ass_private" {
  count = 4
  subnet_id = element([aws_subnet.cloudforce_privateA.id,
    aws_subnet.cloudforce_privateB.id,
    aws_subnet.cloudforce_privateC.id,
  aws_subnet.cloudforce_privateD.id, ], count.index)
  route_table_id = aws_route_table.NAT_Gateway_RT.id
}
