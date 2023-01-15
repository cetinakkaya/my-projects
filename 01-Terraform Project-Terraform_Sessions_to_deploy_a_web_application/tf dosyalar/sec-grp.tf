resource "aws_security_group" "alb_sec" {
  name        = "alb_sec_grp"
  description = "Allow HTTP for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server_sec" {
  name        = "web_server_sec"
  description = "Enable HTTP for Flask App and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "HTTP for Flask"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.alb_sec.id ]
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
  }
}

resource "aws_security_group" "db_sec" {
  name        = "db_sec_grp"
  description = "DB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "DB"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [ aws_security_group.server_sec.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}