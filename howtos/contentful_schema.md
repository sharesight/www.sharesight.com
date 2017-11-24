Contentful's Schema
===================

Contentful comes in via a complex API and gets transformed (heavily) by `contentful_middleman`.  It does a huge amount of data processing and plops the data into `data/[blog]/[posts]`.

Notes:  
- `blog.posts` has a specific `created_at` key on the schema.  This is different than the `_meta.created_at`!
- `blog.posts` has naming such as `featuredImage` and `metaDescription` (non-standard for Contentful).  In older versions of `contentful_middleman`, these were left alone.  In recent versions, these are transformed to `snake_case`, eg. `featured_image`.
