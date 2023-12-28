terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#Create-Vpc
resource "aws_vpc" "MyVpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    name = "MyVpc"
  }
}

#Create-Internet-gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.MyVpc.id

  tags = {
    Name = "igw"
  }
}

#Create-Subnet
resource "aws_subnet" "Subnet" {
  vpc_id     = aws_vpc.MyVpc.id             
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet"
  }
}

#Create-route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.MyVpc.id
                                                  
  route = []                        
  tags = {
    Name = "rt"
  }
}

#Create-route
resource "aws_route" "route" {
  route_table_id            = aws_route_table.rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =  aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.rt]
}

#AWS security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.MyVpc.id

  ingress {
    description      = "HTTPS Traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  ingress {
    description      = "HTTPS Traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 tags = {
    Name = "sg"
  }
}

#Route-Table-Association
resource "aws_route_table_association" "a" {
 # vpc_id      = aws_vpc.MyVpc.id
  subnet_id = aws_subnet.Subnet.id
  route_table_id = aws_route_table.rt.id
}

#Ec2-Instance
resource  "aws_instance" "ansible" {
  ami           = "ami-0759f51a90924c166"
  instance_type = "t2.micro"
  key_name = "pooja"
  subnet_id = aws_subnet.Subnet.id # infomration creation in ec2 in the subnet
  associate_public_ip_address = true
  #vpc_security_group_ids = "aws_security_group_allow_tls.id"

   tags = {
    Name = "ansible"
  }
}

#Public_key_pair
resource  "aws_key_pair" "deployer" {
  key_name   = "pooja"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEunKPW1RPyc/zySboEhJjZ2/DV3ru7VVYwu1o3mgcMz7FUk6WV8umnmDGTYsfXYLi4jkmLOL1oZveTkU43e7gkIxipwQyjecorITEsyVxnzR+EKS/4wSzSS7Y1KvhEtlhB6AUHkMOy0isBW9xr+f/OT1JY3iuev+5+0jDvZ60JygYVXzDFdOkq6BaOjcgFdZIRqsv4C4RelAr1DOmdXrit3pppwpgf0iffqW+MQXfH8K9xOVx+QGI3pBEMQH+NY+M73Xtk+TMGbkyG962Nfx1Ay6IGfcbiPKFe7hhSIff6VuuuE/SpMt8xLJ0KleMI8Os9LKzGW34CtPOndTlnBln5Ft2hbYnH8hehtZQHdeonVB163F8QLosXZxv+ZlNzL6TpKsvyMI0hzlq++CQ009ee7Cu/B6enlMtTGL8rh3ZtHd7JWLK3XC+a3nYI5mIKTXeyMLWMTeurJdtekfCdJzTnpALKtdwKsRW7ajSr6ooh4V6j3nHaZN6aAKRZZlQICk= pooja@localhost.localdomain"
}
