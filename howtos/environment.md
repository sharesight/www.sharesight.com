## Local Environment

As this is a public repo, everything is stored in local environment keys.

#### Environment Settings:
 - Contenful, see `config/contentful.rb`
   - Create your own Contentful Keys!
   - CONTENTFUL_BLOG_ACCESS_TOKEN
   - CONTENTFUL_BLOG_PREVIEW_TOKEN
   - CONTENTFUL_PARTNERS_ACCESS_TOKEN
   - CONTENTFUL_PARTNERS_PREVIEW_TOKEN
 - AWS Deploys, see `config/environment/*.rb`
   - Use your own AWS Keys!
   - AWS_DEPLOY_ACCESS_ID
   - AWS_DEPLOY_SECRET_KEY

#### Travis Specific Environment:
 - For Travis Build Caching via aws-cli (currently linked to the `travis-ci` user, which is currently shared by both [www] and [help]):
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
