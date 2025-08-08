
# Display the S3 bucket name
output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.tasy_chef.bucket
}

# Display the S3 bucket website URL (direct access)
output "s3_website_url" {
  description = "S3 bucket website URL (not recommended for production)"
  value       = "http://${aws_s3_bucket.tasy_chef.bucket}.s3-website-${aws_s3_bucket.tasy_chef.region}.amazonaws.com"
}

# Display the CloudFront domain name
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.tasy_chef_cdn.domain_name
}

# Display the full CloudFront URL (this is what you should use)
output "website_url" {
  description = "Your website URL (use this one!)"
  value       = "https://${aws_cloudfront_distribution.tasy_chef_cdn.domain_name}"
}

# Display CloudFront distribution ID (useful for cache invalidation)
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.tasy_chef_cdn.id
}