resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "media" {
  bucket = local.s3_bucket
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami           = "ami-053b0d53c279acc90" # Ubuntu 22.04 in us-east-1
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 php php-mysql mysql-client -y
              systemctl start apache2
              systemctl enable apache2
              cd /var/www/html
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              cp -r wordpress/* .
              chown -R www-data:www-data /var/www/html
              EOF

  tags = {
    Name = local.instance_name
  }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = local.db_name
  username             = "admin"
  password             = "admin1234"
  skip_final_snapshot  = true
  publicly_accessible  = true
}

resource "aws_lb" "wordpress_alb" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.wordpress_sg.id]
}

resource "aws_lb_target_group" "wordpress_tg" {
  name     = "wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

data "cloudflare_zone" "main" {
  filter = {
    name   = var.cloudflare_zone_name
    status = "active"
    match  = "all"
  }
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_record_name
  content   = aws_lb.wordpress_alb.dns_name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}