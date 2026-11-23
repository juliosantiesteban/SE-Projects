resource "aws_s3_bucket" "sa" {
    #checkov:skip=CKV_AWS_145:Default SSE-S3 encryption is enough here; a KMS CMK adds monthly cost for a learning bucket
  #checkov:skip=CKV_AWS_18:Access logging needs a second bucket and adds cost; not needed for a learning bucket
  #checkov:skip=CKV_AWS_144:Cross-region replication doubles storage cost; single region is fine for learning
  #checkov:skip=CKV2_AWS_61:No lifecycle rules needed; the bucket holds only tiny state files
  #checkov:skip=CKV2_AWS_62:No event consumers exist, so notifications would have no purpose
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

resource "aws_s3_bucket_versioning" "sa" {
  bucket = aws_s3_bucket.sa.id

  versioning_configuration {
    status = "Enabled"
  }
}