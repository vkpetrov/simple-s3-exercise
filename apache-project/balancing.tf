resource "aws_elb" "apache_elb" {
  name    = "apache-elb-${var.env}"
  subnets = module.vpc.public_subnets
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
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = false
    }
  }
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  instance_type = "t3.micro"
  image_id      = "ami-0fec2c2e2017f4e7b"
}
resource "aws_autoscaling_group" "apache_asg" {
  availability_zones = module.vpc.azs
  lifecycle {
    create_before_destroy = false
  }
  name                = "apache_asg-${var.env}"
  launch_template {
    id      = aws_launch_template.apache_lt.id
    version = "$Latest"
  }
  max_size         = 1
  min_size         = 1
  desired_capacity = 1
  force_delete     = true
  load_balancers   = [aws_elb.apache_elb.name]
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Create a Scaling Policy for Scaling Out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  policy_type            = "SimpleScaling"
  cooldown               = "60"
  autoscaling_group_name = aws_autoscaling_group.apache_asg.name

  # Scale Out Trigger
  step_adjustment {
    metric_interval_lower_bound = "0"
    scaling_adjustment          = "1"
    metric_interval_upper_bound = "80"
  }
}

# Create a Scaling Policy for Scaling In
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  policy_type            = "SimpleScaling"
  cooldown               = "60"
  autoscaling_group_name = aws_autoscaling_group.apache_asg.name

  # Scale In Trigger
  step_adjustment {
    metric_interval_lower_bound = "0"
    scaling_adjustment          = "-1"
    metric_interval_upper_bound = "20"
  }
}