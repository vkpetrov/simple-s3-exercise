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
      delete_on_termination = true # I almost got broke because this was set to false initially.
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
  vpc_zone_identifier = module.vpc.private_subnets
  name                = "apache_asg-${var.env}"
  launch_template {
    id      = aws_launch_template.apache_lt.id
    version = "$Latest"
  }
  max_size         = 2
  min_size         = 1
  desired_capacity = 2
  force_delete     = true
  load_balancers   = [aws_elb.apache_elb.name]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  lifecycle {
    create_before_destroy = true
  }

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
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "30"
  scaling_adjustment     = "1"
  autoscaling_group_name = aws_autoscaling_group.apache_asg.name
}

# Create a Scaling Policy for Scaling In
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "30"
  scaling_adjustment     = "-1"
  autoscaling_group_name = aws_autoscaling_group.apache_asg.name
}


resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "apache-cpu-alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors CPU utilization"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn, aws_autoscaling_policy.scale_out_policy.arn]
  dimensions          = { autoscaling_group_name = aws_autoscaling_group.apache_asg.name }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  alarm_name          = "apache-cpu-alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "This metric monitors CPU utilization"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn, aws_autoscaling_policy.scale_in_policy.arn]
  dimensions          = { autoscaling_group_name = aws_autoscaling_group.apache_asg.name }
}