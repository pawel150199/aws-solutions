resource "aws_lambda_function" "add_file_to_s3_lambda" {
  function_name = "add_file_to_s3_lambda_function"
  role          = aws_iam_role.this.arn
  package_type  = "Image"

  image_uri = local.env_vars.lambda.image_uri

  logging_config {
    log_format = "Text"
    log_group  = local.env_vars.lambda.log_group
  }

  environment {
    variables = {
      "S3_BUCKET"     = local.env_vars.lambda.s3_bucket
      "S3_FILENAME"   = local.env_vars.lambda.s3_filename
      "SNS_TOPIC_ARN" = local.env_vars.lambda.sns_topic
    }
  }

  depends_on = [aws_iam_role.this]
}

resource "aws_iam_role" "this" {
  name        = "step-functions-lambda-iam-role"
  description = "Lambda role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = { Name = "step-functions-lambda-iam-role" }

}

resource "aws_iam_policy_attachment" "this" {
  name       = "lambda-policy-attachement"
  roles      = [aws_iam_role.this.name]
  policy_arn = aws_iam_policy.step_functions_iam_policy.arn
}

resource "aws_iam_policy" "step_functions_iam_policy" {

  name        = "aws-iam-policy-step-functions-lambda-role"
  path        = "/"
  description = "AWS IAM Policy for managing step functions lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:AbortMultipartUpload",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::step-functions-export/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "sns:Publish"
      ],
      "Resource": "${aws_sns_topic.step_functions_export.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}
