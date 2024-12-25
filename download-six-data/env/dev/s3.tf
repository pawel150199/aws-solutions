resource "aws_s3_bucket" "rrd_artefacts" {
  bucket = local.env_vars.lambda.s3_bucket
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.rrd_artefacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "step_functions_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.rrd_artefacts.id
  acl        = "private"
}
