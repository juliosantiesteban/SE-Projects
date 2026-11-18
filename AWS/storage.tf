resource "aws_s3_bucket" "sa" {
  bucket = "seportfoliolearning"

  tags = {
    project = "SEPortfolio"
  }
}

# Keep the bucket private
resource "aws_s3_bucket_public_access_block" "sa" {
  bucket                  = aws_s3_bucket.sa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  value = aws_s3_bucket.sa.bucket
}