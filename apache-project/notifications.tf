resource "aws_sns_topic" "asg_alarms" {
  name = "asg-alarms-topic"
}