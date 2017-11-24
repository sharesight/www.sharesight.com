require 'spec_helper'

describe 'Space Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  context "is_category_page?" do
    it "should be false on blog" do
      visit '/blog/'
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be false on a bad blog link" do
      visit '/blog/__fake_link'
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be Blog on the first valid post" do
      post = get_blog_posts().find{ |model| model[:title] }
      visit '/blog/' + @app.post_url(post)
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be true on the first blog category" do
      category = get_blog_categories().find{ |model| model[:name] }
      visit '/blog/' + @app.url_friendly_string(category[:name])
      expect(@app.is_category_page?).to eq(true)
    end

    ## Partners
    it "should be false on partners" do
      visit '/partners/'
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be false on the first valid partner" do
      partner = get_partners_partners().find{ |model| model[:name] }
      visit @app.partner_path(partner)
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be false on a bad partner link" do
      visit '/partners/__fake_link'
      expect(@app.is_category_page?).to eq(false)
    end

    it "should be true on the first partner category" do
      category = get_partners_categories().find{ |model| model[:name] }
      visit '/partners/' + @app.url_friendly_string(category[:name])
      expect(@app.is_category_page?).to eq(true)
    end
  end

  context "space_category_title" do
    it "should be Blog on blog" do
      visit '/blog/'
      expect(@app.space_category_title).to eq('Blog')
    end

    it "should be Blog on a bad blog link" do
      visit '/blog/__fake_link'
      expect(@app.space_category_title).to eq('Blog')
    end

    it "should be Blog on the first valid post" do
      post = get_blog_posts().find{ |model| model[:title] }
      visit '/blog/' + @app.post_url(post)
      expect(@app.space_category_title).to eq('Blog')
    end

    it "should be the Category Name on the first blog category" do
      category = get_blog_categories().find{ |model| model[:name] }
      visit '/blog/' + @app.url_friendly_string(category[:name])
      expect(@app.space_category_title).to eq(category[:name])
    end

    ## Partners
    it "should be Partners on partners" do
      visit '/partners/'
      expect(@app.space_category_title).to eq('Partners')
    end

    it "should be Partners on the first valid partner" do
      partner = get_partners_partners().find{ |model| model[:name] }
      visit @app.partner_path(partner)
      expect(@app.space_category_title).to eq('Partners')
    end

    it "should be Partners on a bad partner link" do
      visit '/partners/__fake_link'
      expect(@app.space_category_title).to eq('Partners')
    end

    it "should be the Category Name on the first partner category" do
      category = get_partners_categories().find{ |model| model[:name] }
      visit '/partners/' + @app.url_friendly_string(category[:name])
      expect(@app.space_category_title).to eq("#{category[:name]} Partners")
    end
  end

  context "space_category_page_title" do
    it "should be correct on blog" do
      visit '/blog/'
      expect(@app.space_category_page_title).to eq('Sharesight Blog')
    end

    it "should be correct on the first valid post" do
      post = get_blog_posts().find{ |model| model[:title] }
      visit '/blog/' + @app.post_url(post)
      expect(@app.space_category_page_title).to eq('Sharesight Blog')
    end

    it "should include the Category Name on the first blog category" do
      category = get_blog_categories().find{ |model| model[:name] }
      visit '/blog/' + @app.url_friendly_string(category[:name])
      expect(@app.space_category_page_title).to eq("#{category[:name]} | Sharesight")
    end

    ## Partners
    it "should be correct on partners" do
      locales.each do |locale|
        visit localize_path('partners', locale_id: locale[:id])
        expect(@app.space_category_page_title).to eq("#{locale[:append_title]} Partners")
      end
    end

    it "should be correct on the first valid partner" do
      locales.each do |locale|
        partner = get_partners_partners().find{ |model| model[:name] }
        visit @app.partner_path(partner, locale_id: locale[:id])
        expect(@app.space_category_page_title).to eq("#{locale[:append_title]} Partners")
      end
    end

    it "should include the Category Name on the first partner category" do
      locales.each do |locale|
        category = get_partners_categories().find{ |model| model[:name] }
        visit localize_path('partners/' + @app.url_friendly_string(category[:name]), locale_id: locale[:id])
        expect(@app.space_category_page_title).to eq("#{category[:name]} Partners | #{locale[:append_title]}")
      end
    end
  end

  context "base_space_category_page_title" do
    it "should be correct on blog" do
      visit '/blog/'
      expect(@app.base_space_category_page_title).to eq('Sharesight Blog')
    end

    it "should be correct on the first valid post" do
      post = get_blog_posts().find{ |model| model[:title] }
      visit '/blog/' + @app.post_url(post)
      expect(@app.base_space_category_page_title).to eq('Sharesight Blog')
    end

    it "should include the Category Name on the first blog category" do
      category = get_blog_categories().find{ |model| model[:name] }
      visit '/blog/' + @app.url_friendly_string(category[:name])
      expect(@app.base_space_category_page_title).to eq("#{category[:name]} | Sharesight")
    end

    ## Partners
    it "should be correct on partners" do
      locales.each do |locale|
        visit localize_path('partners', locale_id: locale[:id])
        expect(@app.base_space_category_page_title).to eq("#{default_locale_obj[:append_title]} Partners")
      end
    end

    it "should be correct on the first valid partner" do
      locales.each do |locale|
        partner = get_partners_partners().find{ |model| model[:name] }
        visit @app.partner_path(partner, locale_id: locale[:id])
        expect(@app.base_space_category_page_title).to eq("#{default_locale_obj[:append_title]} Partners")
      end
    end

    it "should include the Category Name on the first partner category" do
      locales.each do |locale|
        category = get_partners_categories().find{ |model| model[:name] }
        visit localize_path('partners/' + @app.url_friendly_string(category[:name]), locale_id: locale[:id])
        expect(@app.base_space_category_page_title).to eq("#{category[:name]} Partners | #{default_locale_obj[:append_title]}")
      end
    end
  end
end
