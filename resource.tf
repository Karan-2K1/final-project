# Define a unique bucket name using locals
locals {
  bucket_name = "web-bucket-mathesh-2025" # Make it unique as you want
}

# Create S3 Bucket
resource "aws_s3_bucket" "bucket1" {
  bucket = local.bucket_name
}

# Disable public access block (so it can be a public website)
resource "aws_s3_bucket_public_access_block" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = local.bucket_name
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  acl          = "public-read"    # ✅ This line added
}

# Upload error.html
resource "aws_s3_object" "error" {
  bucket       = local.bucket_name
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  acl          = "public-read"    # ✅ This line added
}

# Configure S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Set bucket policy to allow public read access
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.bucket1.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = [
          "${aws_s3_bucket.bucket1.arn}/*"
        ]
      }
    ]
  })
}
