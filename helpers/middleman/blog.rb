# frozen_string_literal: true

require 'ostruct'
load File.expand_path('../blog_helper.rb', __dir__)

module MiddlemanBlogHelpers
  def blog_posts(order: :latest_first)
    @blog_posts ||= {}
    return @blog_posts[order] if @blog_posts[order]

    @blog_posts[order] ||= case order
                           when :oldest_first
                             data.blog.posts.values.sort do |a, b|
                               a['created_at'] <=> b['created_at']
                             end
                           when :latest_first
                             data.blog.posts.values.sort do |a, b|
                               b['created_at'] <=> a['created_at']
                             end
                           else
                             data.blog.posts.values
                           end
  end

  def blog_posts_for_menu
    category_name_regexes = [
      /Company News/,
      /Investing Tips/,
      /Release Notes/,
      /Sharesight Features .* Tips/
    ]

    # get and cache a list of categories for the menu's list of blog posts
    @__menu_blog_post_category_ids ||= blog_categories.select do |category|
      category_name_regexes.any? do |name_regex|
        category[:name] =~ name_regex
      end
    end.map do |category|
      category[:id]
    end

    # filter the blog posts by these categories
    posts = blog_posts(order: :latest_first).select do |post|
      post.categories&.find do |category|
        @__menu_blog_post_category_ids.include?(category[:id])
      end
    end

    # return the first 3
    posts.first(3)
  end

  def post_url(post)
    unlocalized_url("blog/#{BlogHelper.url_slug(post)}")
  end

  def blog_categories
    @blog_categories ||= begin
      categories = []
      collection = data.blog.posts
                       .map { |tuple| tuple[1] }
                       .select { |model| BlogHelper.is_valid_post?(model) }

      categories_collection = data.blog.categories
                                  .map { |tuple| tuple[1] }
                                  .select { |model| BlogHelper.is_valid_category?(model) }

      collection = categories_collection.each do |category|
        set = collection.select do |model|
          # models that have the category id
          model[:categories]&.find { |model_category| model_category[:id].include?(category[:id]) }
        end

        categories.push({
                          id: category[:id],
                          name: category[:name],
                          description: category[:description],
                          _meta: category[:_meta],
                          path: "blog/#{url_friendly_string(category[:name])}",
                          url_slug: url_friendly_string(category[:name]),
                          count: set.length,
                          set: set
                        })
      end

      categories.sort_by { |x| x[:name] }
    end
  end

  # NOTE: This is a very specific, fragile, and magical category!
  # We hack together a blog category to do a few specific things on the Sharesight20 category.
  # If this category is removed or renamed, there may be some issues...
  def sharesight20_category
    @sharesight20_category ||= blog_categories.find { |category| category[:name].include?('Sharesight20') }
  end
end
