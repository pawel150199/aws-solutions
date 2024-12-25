resource "aws_sns_topic" "step_functions_export" {
  name = "step-functions-topic"
}

resource "aws_sns_topic_subscription" "step_functions_notification" {
  topic_arn = aws_sns_topic.step_functions_export.arn
  protocol  = "email"
  endpoint  = "pawel.polski99@gmail.com"
}
