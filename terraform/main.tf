provider "aws" {
  region = "ap-south-1"
}

# ─── VPC & Networking ────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "devops-react-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "devops-react-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "devops-react-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "devops-react-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─── Security Group ──────────────────────────────────────────────────────────

resource "aws_security_group" "app_sg" {
  name        = "devops-react-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-react-sg" }
}

# ─── Key Pair ────────────────────────────────────────────────────────────────

resource "aws_key_pair" "deployer" {
  key_name   = "devops-react-key"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
}

# ─── EC2 Instance ────────────────────────────────────────────────────────────

resource "aws_instance" "app" {
  ami                    = "ami-0f5ee92e2d63afc18" # Amazon Linux 2 - ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = { Name = "devops-react-app" }
}

# ─── Outputs ─────────────────────────────────────────────────────────────────

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "URL to access the app"
  value       = "http://${aws_instance.app.public_ip}"
}
