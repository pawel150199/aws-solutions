resource "aws_s3_bucket" "step_functions_bucket" {
  bucket = local.env_vars.lambda.s3_bucket
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.step_functions_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "step_functions_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.step_functions_bucket.id
  acl        = "private"
}

# Lifecycle Policy configuration
resource "aws_s3_bucket_lifecycle_configuration" "step_functions_bucket_lifecycle" {
  bucket = aws_s3_bucket.step_functions_bucket.id

  rule {
    id     = "auto-delete-objects-after-24-hours"
    status = "Enabled"

    filter {
      prefix = "output.csv"
    }

    expiration {
      days = 1 # Delete after 1 days (24 hours)
    }
  }
}
