Middleman Basics
================
Middleman is a static site generator. It runs ruby code over the information
stored in `data/` to build the site.

Install the Middleman gem
-------------------------
`gem install middleman -v 3.4.1`

Note: the latest version (v4.x) would require a pretty big refactor as `middleman`
isn't very well documented (even the upgrade docs are lacking) and `middleman-contentful`
does not have full support for v4.x – only via an experimental branch.

Checkout the repo
-----------------
`git clone git@github.com:sharesight/www.sharesight.com.git`

Get things ready:

`cd www.sharesight.com; bundle install`

Now you can build the current version...

`middleman build`

If you run `middleman server` or just plain `middleman` it serves locally for
development.

Making Changes
--------------
The basic structure of the site is in `/source/`. This includes html, erb, assets
and all the stuff you expect.

Your ruby code can also grab anything in the `/data/`
directory YAML files and use it, e.g.:
```
<% data.locales.each do |locale| %>
  …
<% end %>
```

Branches
--------
1. When you push to `develop`, the travis build will run `middleman build`.
and if there are no errors, it will also deploy the site to the testing `https://staging-www.sharesight.com/` site.
2. When finished, merge to master. The master build also deploys
automatically to `https://www.sharesight.com/` on a successful build.

Middleman Docs
--------------
[Basics: `https://middlemanapp.com/basics/directory-structure/`](https://middlemanapp.com/basics/directory-structure/)  
[Advanced: `https://middlemanapp.com/advanced/configuration/`](https://middlemanapp.com/advanced/configuration/)

Working With the Code
---------------------
You may notice a lot of `*.second`, especially `post.second`, when iterating over datasets.  This is the `array` method `second` (eg. `array[1]`) as each dataset is an array of `[id, data]` like `['afsj892j89f3jawiof', { name: '...', title: '...', content: '...', ... }]`.

There are a lot of global variables defined by Middleman and even by extensions.  For example: Middleman exposes the globals `data`, `config`, `page`, `proxy` and `middleman-pagination` exposes `pagination` (which is only accessible after `activate :pagination`.  Extensions may not always work due to lackluster lifecycles.  For example, I was unable to split pagination out into an extension as it couldn't hook in at the right time between config and build.

In an extension, these globals can be accessed in lifecycle events beginning with `after_configuration` via the global variable `app`, eg `app.config[:env_name]`.  On the `initialize` method, most globals are not available, even via the passed `app` – only static methods and variables seem to be accessible.

The `locals` object on a template pushes in local variables to templates as well.
