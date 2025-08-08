

# this block of code creates cloud front distribution with name tasty-chef-cdn
resource "aws_cloudfront_distribution" "tasy_chef_cdn" {

  # this block of code creates origin acess control (from where cloud front will take files to host)
  origin {
    domain_name              = aws_s3_bucket.tasy_chef.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.tasy_chef_oac.id
    origin_id                = "S3-tasy-chef"
  }

  # this block of code enables ipv6 access from all over the world
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for Tasy Chef website"

  # this line sets the default index.html page when someone visits your site
  default_root_object = "index.html"

  
  default_cache_behavior {
    # Which HTTP methods are allowed
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    # Which methods CloudFront will cache
    cached_methods = ["GET", "HEAD"]

    target_origin_id = "S3-tasy-chef"
    compress         = true # Compress files for faster loading

    # Force HTTPS for security
    viewer_protocol_policy = "redirect-to-https"

    # Configure what gets forwarded to S3
    forwarded_values {
      query_string = false # Don't forward URL parameters
      cookies {
        forward = "none" # Don't forward cookies
      }
    }

    # How long to cache content (in seconds)
    min_ttl     = 0
    default_ttl = 3600  # 1 hour
    max_ttl     = 86400 # 24 hours
  }

  # Handle 404 errors by showing the main page (good for single-page apps)
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Geographic restrictions (none in this case)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL certificate configuration
  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's free SSL certificate
  }

  # Tags for organization
  tags = {
    Name        = "Tasy Chef CDN"
    Environment = "Production"
  }
}