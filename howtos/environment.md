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
   - Use your own AWS Keys! The Github Actions secrets are tied to the user `www_deploy`
   - AWS_DEPLOY_ACCESS_ID
   - AWS_DEPLOY_SECRET_KEY

Example local `.envrc` file for development—using direnv (https://direnv.net/):
```
# .envrc
export CONTENTFUL_BLOG_ACCESS_TOKEN=DELIVERY_TOKEN_HERE
export CONTENTFUL_BLOG_PREVIEW_TOKEN=PREVIEW_TOKEN_HERE
export CONTENTFUL_PARTNERS_ACCESS_TOKEN=DELIVERY_TOKEN_HERE
export CONTENTFUL_PARTNERS_PREVIEW_TOKEN=PREVIEW_TOKEN_HERE
export CONTENTFUL_LANDING_PAGES_ACCESS_TOKEN=DELIVERY_TOKEN_HERE
export CONTENTFUL_LANDING_PAGES_PREVIEW_TOKEN=PREVIEW_TOKEN_HERE
```

#### Github Actions Secrets
  - All of these go into https://github.com/sharesight/www.sharesight.com/settings/secrets under the same name.

#### Contentful Webhooks
  - API Webhooks require a Personal Access Token with `repo_deployment` access from Github to this branch for API Authorization.  We use a Machine User for this.
