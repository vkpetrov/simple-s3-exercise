resource "aws_elb" "apache_elb" {
  name    = "apache-elb-${var.env}"
  subnets = data.terraform_remote_state.s3_remote_state.outputs.public_subnets
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = local.common_tags
}


resource "aws_launch_template" "apache_lt" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = false
    }
  }
  cpu_options {
    core_count = 2
    threads_per_core = 2
  }
  instance_type = "t3.micro"
  image_id = "ami-0fec2c2e2017f4e7b"
}
resource "aws_launch_configuration" "apache_lc" {
  lifecycle {
    create_before_destroy = true
  }
  name                        = "apache_lc-${var.env}"
  name_prefix                 = "apache-lc-${var.env}"
  associate_public_ip_address = false
  instance_type               = "t3.micro"
  image_id                    = "VALUE_TO_UPDATE"
}

resource "aws_autoscaling_group" "apache_asg" {
  lifecycle {
    create_before_destroy = false
  }
  vpc_zone_identifier  = data.terraform_remote_state.s3_remote_state.outputs.private_subnets
  name                 = "apache_asg-${var.env}"
  launch_configuration = aws_launch_configuration.apache_lc.id
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  force_delete         = true
  load_balancers       = [aws_elb.apache_elb.name]
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}