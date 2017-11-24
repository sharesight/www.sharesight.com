require 'cgi'

module CapybaraBlogHelpers
  def get_blog_posts()
    posts = Capybara.app.data.blog.posts.map{ |tuple| tuple[1] }
    posts = posts.map do |post|
      post = OpenStruct.new(post) # hash does not like being mutable
      post.path = base_path("blog/#{BlogHelper::url_slug(post)}")
      post.url = base_url(post.path)

      # The browser will do this when it parses `&amp; => &`
      post.title = post.title && CGI::unescapeHTML(post.title)
      post.meta_description = post.meta_description && CGI::unescapeHTML(post.meta_description)

      # Mimic layouts/partials/head
      post.page_title = "#{BasicHelper.replace_quotes(post.title)} | #{Capybara.app.default_locale_obj[:append_title]}"
      post.meta_description = BasicHelper.replace_quotes(post.meta_description)
      post
    end

    return posts
  end

  def get_blog_authors()
    return Capybara.app.data.blog.authors.map{ |tuple| tuple[1] }
  end

  def get_blog_categories(check_length: true, all: false)
    categories = Capybara.app.data.blog.categories.map{ |tuple| tuple[1] }
    categories = categories.select{ |category| category&.name } # only categories with a truthy name
    categories << OpenStruct.new({ name: 'All' }) if all

    # remap to new categories
    categories = categories.map do |category|
      category = OpenStruct.new(category) # category object does not like being mutable
      category.title = if category.name == 'All'
        then 'Blog'
        else category.name
        end
      category[:description] = category[:description] || locale_page('blog', Capybara.app.default_locale_obj)[:description]
      category.page_title = if category.name == 'All'
        then 'Sharesight Blog'
        else "#{BasicHelper.replace_quotes(category.title)} | #{Capybara.app.default_locale_obj[:append_title]}"
        end
      category.path = if category.name == 'All'
        then base_path("blog")
        else base_path("blog/#{Capybara.app.url_friendly_string(category.name)}")
        end
      category.url = base_url(category.path)

      # array of posts where one of the post_categories equals this one
      category.posts = get_blog_posts()

      if category.name != 'All'
        category.posts = category.posts.select{ |post|
          post.categories.select{ |post_category| post_category.id == category.id }.length >= 1 rescue false
        }
      end

      category # return to map
    end

    return categories unless check_length

    # only take categories with posts
    return categories.select{ |category| category.posts&.length >= 1 }
  end
end
