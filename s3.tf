
# this block of code tells which terraform version to use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# this block of code tells terraform in which region to create s3 bucket in
provider "aws" {
  region = "us-east-1" 
}

# this block of code creates s3 bucket with name tasty-chef
resource "aws_s3_bucket" "tasy_chef" {
  bucket = "tasy-chef" 

  tags = {
    Name        = "Tasy Chef Website"
    Environment = "Production"
  }
}

# this block of code makes the s3 bucket appropriate for website hosting
resource "aws_s3_bucket_website_configuration" "tasy_chef_website" {
  bucket = aws_s3_bucket.tasy_chef.id

  # it tells what to load first when someone access website
  index_document {
    suffix = "index.html"
  }

  #this block of code shows error page when website fails to load
  error_document {
    key = "index.html"
  }
}

# this block of code uploades all the files from index,css,js files from tasty-master and uploads to s3
resource "aws_s3_object" "website_files" {
  # This will find all files in the tasty-master folder
  for_each = fileset("${path.module}/tasty-master", "**/*")

  bucket = aws_s3_bucket.tasy_chef.id
  key    = each.value                                  # The file path in S3
  source = "${path.module}/tasty-master/${each.value}" # Local file path

  # Set the correct content type for different file types
  content_type = lookup({
    "html"  = "text/html",
    "css"   = "text/css",
    "js"    = "application/javascript",
    "png"   = "image/png",
    "jpg"   = "image/jpeg",
    "jpeg"  = "image/jpeg",
    "gif"   = "image/gif",
    "svg"   = "image/svg+xml",
    "ttf"   = "font/ttf",
    "woff"  = "font/woff",
    "woff2" = "font/woff2",
    "eot"   = "application/vnd.ms-fontobject"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")

  # This ensures files are re-uploaded if they change
  etag = filemd5("${path.module}/tasty-master/${each.value}")
}

# this block of code allows cloidfron to access s3 bucket content
resource "aws_cloudfront_origin_access_control" "tasy_chef_oac" {
  name                              = "tasy-chef-oac"
  description                       = "Origin Access Control for Tasy Chef S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy - allows CloudFront to access the bucket securely
resource "aws_s3_bucket_policy" "tasy_chef_policy" {
  bucket = aws_s3_bucket.tasy_chef.id

  # This policy allows only CloudFront to access the S3 bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.tasy_chef.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.tasy_chef_cdn.arn
          }
        }
      }
    ]
  })
}