data "aws_vpc" "default" {
  default = true
} 

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}
resource "aws_db_instance" "mysql" {
  allocated_storage = "10"
  instance_class = "db.t2.micro"
  allow_major_version_upgrade = "false"
  auto_minor_version_upgrade = "false"
  backup_retention_period = "0"
  identifier = "phonebook-db"
  db_name = "clarusway_phonebook"
  skip_final_snapshot = true
  vpc_security_group_ids = [ aws_security_group.db_sec.id ]
  engine = "mysql"
  engine_version = "8.0.28"
  username = "admin"
  password = "Clarusway_1"
  port = "3306"
  publicly_accessible = "true"
}

resource "github_repository_file" "dbendpoint" {
  content = aws_db_instance.mysql.address
  file = "dbserver.endpoint"
  repository = var.github_repo_name
  branch = var.github_repo_branch_name
  overwrite_on_create = true
}

resource "aws_launch_template" "server_lt" {
  name = "Flask_LT"
  image_id = var.ec2_ami
  key_name = "firstkey"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.server_sec.id ] 
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
  user_data = filebase64("${path.module}/userdata.sh")
}

resource "aws_lb_target_group" "tg" {
    name = "Phonebook-Trgt"
    port = "80"
    protocol = "HTTP"
    target_type = "instance" 
    health_check {
      unhealthy_threshold = "3"
      healthy_threshold = "2"
    }
    vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "alb" {
    name = "Phonebook-LB"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.alb_sec.id ]
    subnets = data.aws_subnets.subnets.ids
}

resource "aws_lb_listener" "alb-listener" {
    default_action {
      target_group_arn = aws_lb_target_group.tg.arn
      type = "forward"
    }
    load_balancer_arn = aws_lb.alb.arn
    port = "80"
    protocol = "HTTP"
}

resource "aws_autoscaling_group" "asg" {
    name = "phonebook-asg"
    vpc_zone_identifier = aws_lb.alb.subnets
    desired_capacity = 2
    min_size = 1
    max_size = 3
    health_check_grace_period = 300
    health_check_type = "ELB"
    launch_template {
      id = aws_launch_template.server_lt.id
      version = "$Latest"
    }
    target_group_arns = [ aws_lb_target_group.tg.arn ]
}
