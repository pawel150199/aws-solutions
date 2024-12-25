resource "aws_iam_role" "step_function_role" {
  name = "step_function_role"

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

resource "aws_iam_role_policy" "step_function_policy" {
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = "${aws_lambda_function.add_file_to_s3_lambda.arn}"
      },
      {
        Action = [
          "SNS:Publish",
        ],
        Effect = "Allow"
        Resource = [
          "${aws_sns_topic.step_functions_export.arn}"
        ]
      }
    ]
  })
}


resource "aws_sfn_state_machine" "example" {
  name     = "example-step-function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "Comment": "A simple example of a Step Function that triggers a Lambda",
  "StartAt": "InvokeLambda",
  "States": {
    "InvokeLambda": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.add_file_to_s3_lambda.arn}",
      "Next": "Choice",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "SNS Publish Fail",
          "ResultPath": null
        }
      ],
      "TimeoutSeconds": 60,
      "Retry": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "BackoffRate": 2,
          "IntervalSeconds": 15,
          "MaxAttempts": 3,
          "MaxDelaySeconds": 20,
          "Comment": "Retry if fail"
        }
      ]
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.statusCode",
          "NumericEquals": 200,
          "Next": "SNS Publish Success"
        }
      ],
      "Default": "SNS Publish Fail"
    },
    "SNS Publish Fail": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "The output.csv file has not been successfully saved.",
        "TopicArn": "${aws_sns_topic.step_functions_export.arn}"
      },
      "Next": "Fail"
    },
    "Fail": {
      "Type": "Fail"
    },
    "SNS Publish Success": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "The output.csv file has been successfully saved to the S3 bucket: ${aws_s3_bucket.step_functions_bucket.bucket}.",
        "TopicArn": "${aws_sns_topic.step_functions_export.arn}"
      },
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    }
  }
}
EOF
}
