## Local Environment

As this is a public repo, everything is stored in local environment keys.

#### Environment Settings:
 - Contenful, see `config/contentful.rb`
   - Create your **own** Contentful keys for each space.
   - Blog Space: https://app.contentful.com/spaces/91sm3pewxzag/api/keys
     - CONTENTFUL_BLOG_ACCESS_TOKEN
     - CONTENTFUL_BLOG_PREVIEW_TOKEN
   - Partners Space: https://app.contentful.com/spaces/rafbawofr5bl/api/keys
     - CONTENTFUL_PARTNERS_ACCESS_TOKEN
     - CONTENTFUL_PARTNERS_PREVIEW_TOKEN
   - Landing Pages Space: https://app.contentful.com/spaces/cbgsdqa84fjb/api/keys
     - CONTENTFUL_LANDING_PAGES_ACCESS_TOKEN
     - CONTENTFUL_LANDING_PAGES_PREVIEW_TOKEN
 - For deploys to AWS, see `config/environment/*.rb`
   - Use your own AWS Keys!
   - AWS_DEPLOY_ACCESS_ID
   - AWS_DEPLOY_SECRET_KEY

#### Travis Specific Environment:
 - For Travis Build Caching via aws-cli (currently linked to the `travis-ci` user, which is currently shared by both [www] and [help]):
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
