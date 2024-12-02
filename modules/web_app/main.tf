resource "aws_instance" "web_app" {
  count = var.instance_count

  ami = "ami-04c913012f8977029"
  instance_type = var.instance_type
  #subnet_id = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]
  subnet_id = local.selected_subnet_ids[count.index % length(local.selected_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web_app.id]
  user_data = templatefile("${path.module}/init-script.sh", {file_content = "webapp-#${count.index}"})

  key_name = "yl-key-pair"
  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}-webapp-${count.index}"
  }
}

resource "aws_security_group" "web_app" {
  name_prefix = "${var.name_prefix}-webapp"
  description = "Allow traffic to webapp"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_lb_target_group" "web_app" {
  count = var.alb_listener_arn != "" ? 1 : 0
  name = "${var.name_prefix}-targetgroup"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selected.id

  health_check {
    port = 80
    protocol = "HTTP"
    timeout = 3
    interval = 5
  }
}

resource "aws_lb_target_group_attachment" "web_app" {
  count = var.alb_listener_arn != "" ? length(aws_instance.web_app) : 0
  target_group_arn = aws_lb_target_group.web_app[0].arn
  target_id = aws_instance.web_app[count.index].id
  port = 80
}

resource "aws_lb_listener_rule" "web_app" {
  count = var.alb_listener_arn != "" ? 1 : 0
  listener_arn = var.alb_listener_arn
  priority = 49999

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web_app[0].arn
  }

  condition {
    path_pattern {
      values = ["/${var.name_prefix}"]
    }
  }

}

locals {
  selected_subnet_ids = var.public_subnet ? data.aws_subnets.public.ids : data.aws_subnets.private.ids
}