# Sharesight Static Website

![Run Tests and Deploy](https://github.com/sharesight/www.sharesight.com/workflows/Run%20Tests%20and%20Deploy/badge.svg)

## Dependencies

- Ruby 2.4.2+
- Middleman 3.4.1

## Installation

1. Clone this repo into a local directory
2. Change to your new local directory
3. Setup local environment keys.  `.envrc` works great!  See `howtos/environment.md`.
4. `bundle install && yarn`
5. `yarn start` – it's not a javascript package, but it's helpful nevertheless

Individual Commands (see package.json):
1. Load content: `bundle exec middleman contentful`
2. Build the site: `bundle exec middleman build`
3. Or run a local server: `bundle exec middleman`


## Testing

Most things are tested – both in `rspec`.  Every page is tested that it renders, has a title, meta tags, etc.

You would need load up Contentful first.

Commands (see package.json):
 - `yarn test`
 - `yarn rspec` / `yarn rspec:tdd`


## Testing Coverage Holes

	1. Extensions are not tested
	2. The logic in the config file is not tested.


## Cloudfront Components:
 - See https://www.github.com/sharesight/static-cloudfront


## Manual Deploys

The website automatically deploys to staging and production via Github Actions, so normally you don't need to deploy anything manually.

If you **must** force a local deploy, ensure your environment is all setup (see Environment Configuration), and run this, where `env=production|staging`..  See Github Actions workflow for full details how it does it.

		git checkout [branch]
		git pull origin [branch]
		APP_ENV=[env] bundle exec middleman build
		APP_ENV=[env] bundle exec middleman s3_sync


## CI/CD

1. Github Actions manages all of our testing and deployments.  This requires a fair bit of setup.  See `howtos/environment.md`.
	- Deploys whenever pushed to `develop` or `master` (eg. commit, pull request merge, etc).
	- Deploys whenever a `deployment` is trigger (eg. an inbound API action from Contentful).
2. Contentful deploys automatically via a [Create Deployments API webhook](https://developer.github.com/v3/repos/deployments/).
	- This requires a Personal Access Token from an authorized user to make this request.  Sharesight has a machine user to hold this key and it lives as a secret in Contentful.


### Building/Deploying to STAGING:

1. Create a PR
2. Merge PR into `develop` branch.
3. Github Actions will deploy it to `staging-www.sharesight.com`.
4. Once build is complete, may take up to 15 minutes to resolve caches.


### Building/Deploying to PRODUCTION:

1. Merge PR into `master` branch.
2. Github Actions will deploy it to `www.sharesight.com`.
3. Once build is complete, may take up to 15 minutes to resolve caches.


## How to add a new Locale

0. Use proper language and country codes – there's a reason why UK is GB.  https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
1. Open `data/locales.json` and copy one of the existing locales.  *The first locale is the default: global*
 	Ensure to maintain capitalization – the `id` field should be lowercased.
2. Ensure the Helpsite and Marketing site have the same locales!  Else you will link to a non-existent locale.

Do note, the default_locale_id is set in config.rb.


## How to change the redirection rules on Amazon S3

This is now done in https://github.com/sharesight/static-cloudfront, see `lambda-viewer-request/redirects/…`
