resource "aws_lambda_function" "rrd_downloader_lambda" {
    function_name = "rrd_downloader_lambda_function"
    role          = aws_iam_role.this.arn
    package_type  = "Image"

    image_uri = local.env_vars.lambda.image_uri

    logging_config {
        log_format = "Text"
        log_group  = local.env_vars.lambda.log_group
    }

    depends_on = [ aws_iam_role.this ]
}

resource "aws_iam_role" "this" {
  name        = "rrd-downloader-lambda-iam-role"
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
      managed_policy_arns = [
    aws_iam_policy.step_functions_iam_policy.arn,
  ]

  tags = { Name = "rrd-downloader-lambda-iam-role" }

}

resource "aws_iam_policy" "step_functions_iam_policy" {
 
  name         = "aws-iam-policy-rrd-downloader-lambda-role"
  path         = "/"
  description  = "AWS IAM Policy for managing lambda role"
  policy = <<EOF
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
        "arn:aws:s3:::rrd-artifactst/*"
      ],
      "Effect": "Allow"
    },
  ]
}
EOF
}