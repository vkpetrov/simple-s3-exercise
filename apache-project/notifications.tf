resource "aws_sns_topic" "asg_alarms" {
  name = "asg-alarms-topic"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "apache-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors CPU utilization"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn, aws_autoscaling_policy.scale_out_policy.arn, aws_autoscaling_policy.scale_in_policy.arn]
}