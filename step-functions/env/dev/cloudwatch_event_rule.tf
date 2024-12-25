resource "aws_cloudwatch_event_rule" "cloudwatch_rate_config" {
  name        = "${local.env_vars.project_name}-cloudwatch-event-rule"
  description = "Cloudwatch event rule for trigger AWS Step Function"

  schedule_expression = "rate(90 days)"
}

resource "aws_cloudwatch_event_target" "trigger_step_function" {
  target_id = "trigger_step_function"
  arn       = aws_sfn_state_machine.example.arn
  rule      = aws_cloudwatch_event_rule.cloudwatch_rate_config.name
  role_arn  = aws_iam_role.cloudwatch_event_rule_role.arn

  input = jsonencode({
    content = "Example execution"
  })
}

resource "aws_iam_role" "cloudwatch_event_rule_role" {
  name = "cloudwatch_event_rule_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_event_rule_policy" {
  role = aws_iam_role.cloudwatch_event_rule_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution",
        ]
        Effect   = "Allow"
        Resource = "${aws_sfn_state_machine.example.arn}"
      }
    ]
  })
}
