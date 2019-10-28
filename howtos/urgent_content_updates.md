# Urgent Content Update

If there's an urgent content fix, just change it.  CI/CD will handle the rest.  You can deploy locally if absolutely necessary.

CI/CD will then rebuild the site (pulling the latest info from Contentful) and push it to the S3 bucket.

Expect Cloudfront caches of the old content to remain around a little while (up to a couple of hours some times). To confirm your changes are there, check the direct link to the S3 bucket: https://middleman-www.s3-website-us-east-1.amazonaws.com

You can also clear Cloudfront Caches (NOTE: This is slow and can even cost some money).
