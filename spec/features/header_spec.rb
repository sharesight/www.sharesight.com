require 'spec_helper'

describe 'Header', type: :feature do

  context "navigation" do
    before :each do
      visit '/'
    end

    context 'desktop' do
      Capybara.app.data.locales.each do |locale_obj|
        it "#{locale_obj[:country]} should have all expected links" do
          visit locale_obj[:path] # eg. /, /ca/, /uk/, etc…

          links = page.all(:css, 'nav [role="menubar"] a[href]')

          expected_links = [
            # label, path, title

            # Features:
            ["Performance", '/TODO'],
            ["Dividends", '/TODO'],
            ["Tax Reporting", '/TODO'],
            ["Supported Investments", '/TODO'],
            ["Supported Exchanges", localize_url('supported-stock-exchanges-and-managed-funds', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],
            ["Supported Brokers", localize_url('supported_brokers', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],
            # ["Pricing", localize_path('pricing', locale_id: locale_obj[:id])], # NOTE: Mobile-only!
            ["Frequently Asked Questions", localize_path('faq', locale_id: locale_obj[:id])],
            ["Data Security", localize_url('how-sharesight-protects-your-data-', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],

            # Benefits:
            ["Investors", '/TODO'],
            ["Read the Reviews", localize_path('reviews', locale_id: locale_obj[:id])],
            ["Finance Professionals", localize_path('pro', locale_id: locale_obj[:id])],
            ["Finance Companies", localize_path('become-a-partner', locale_id: locale_obj[:id])],

            # Pricing:
            ["Pricing", localize_path('pricing', locale_id: locale_obj[:id])],

            # Resources:
            ["About Sharesight", localize_path('about-sharesight', locale_id: locale_obj[:id])],
            ["Executive Team", localize_path('team', locale_id: locale_obj[:id])],
            ["Reviews", localize_path('reviews', locale_id: locale_obj[:id])],

            ["Partner Directory", localize_path('partners', locale_id: locale_obj[:id])],
            ["Become a Partner", localize_path('become-a-partner', locale_id: locale_obj[:id])],
            ["Become an Affiliate", localize_path('affiliates', locale_id: locale_obj[:id])],
            ["sales@sharesight.com", 'mailto:sales@sharesight.com'],

            ["Help Centre", Capybara.app.config[:help_url]],
            ["Sharesight API", Capybara.app.config[:api_url]],
            ["Webinars & Events", localize_path('events', locale_id: locale_obj[:id])],

            ["From the Blog", base_url("blog")],
            # The Blog Links are pushed in below.
          ]

          # Uses the blog_posts_for_menu helper!
          Capybara.app.blog_posts_for_menu.each do |blog_post|
            expected_links.push([blog_post[:title], Capybara.app.post_url(blog_post)])
          end

          expect(links.length).to eq(expected_links.length)

          # iterate through all links on the page and find the expectations
          links.each do |link|
            matched_link = expected_links.find do |expected_link|
              link.text.include?(expected_link[0])
            end

            expect(matched_link).to_not(be_nil, "Unexpected link '#{link.text}' in #{expected_links}")

            expected_href = matched_link[1]
            if expected_href
              expect(link[:href]).to(match(expected_href), "Link '#{link.text}' did not match expected href of '#{expected_href}', got #{link[:href]}.")
            end

            expected_links.delete(matched_link)
          end

          expect(expected_links.length).to(eq(0), "Found leftover links in expected_links: #{expected_links}")
        end
      end

      it "has expected menus with expected attributes to be a menu" do
        menus = page.all(:css, 'nav [role="menubar"] li')
        expect(menus.length).to eq(4)

        expect(menus[0].text).to start_with('Features')
        expect(menus[0]).to have_css('button[aria-haspopup="true"][aria-expanded="false"][aria-controls="menu-Features"]', text: 'Features')
        expect(menus[0]).to have_css('#menu-Features[role="menu"][aria-labelledby="nav-Features"]')

        # Pricing has no menu!
        expect(menus[2].text).to eq('Pricing')
        expect(menus[2]).to have_css('a[href]', text: 'Pricing')
        expect(menus[2]).not_to have_css('button')
        expect(menus[2]).not_to have_css('#menu-Pricing')

        expect(menus[1].text).to start_with('Benefits')
        expect(menus[1]).to have_css('button[aria-haspopup="true"][aria-expanded="false"][aria-controls="menu-Benefits"]', text: 'Benefits')
        expect(menus[1]).to have_css('#menu-Benefits[role="menu"][aria-labelledby="nav-Benefits"]')

        expect(menus[3].text).to start_with('Resources')
        expect(menus[3]).to have_css('button[aria-haspopup="true"][aria-expanded="false"][aria-controls="menu-Resources"]', text: 'Resources')
        expect(menus[3]).to have_css('#menu-Resources[role="menu"][aria-labelledby="nav-Resources"]')
      end

      it "has a login and signup button" do
        links = page.all(:css, 'nav .nav__ctas a[href].nav__cta')

        expect(links.length).to eq(2)
        expect(links[0].text).to eq('Log In')
        expect(links[0][:href]).to eq(Capybara.app.config[:login_url])

        expect(links[1].text).to include('Get Sharesight Free')
        expect(links[1][:href]).to eq(Capybara.app.config[:signup_url])
      end

      it "pro has a different signup url" do
        visit '/pro'

        links = page.all(:css, 'nav .nav__ctas a[href].nav__cta')

        expect(links.length).to eq(2)
        expect(links[0].text).to eq('Log In')
        expect(links[0][:href]).to eq(Capybara.app.config[:login_url])

        expect(links[1].text).to include('Get Sharesight Free')
        expect(links[1][:href]).to eq(Capybara.app.config[:pro_signup_url])
      end
    end

    context 'mobile' do
      it 'has a hamburger menu' do
        hamburger = page.all(:css, 'nav #nav__hamburger[aria-controls="mobile-nav"][aria-label]')

        expect(hamburger.length).to eq(1)
      end

      Capybara.app.data.locales.each do |locale_obj|
        it "#{locale_obj[:country]} should have all expected links" do
          visit locale_obj[:path] # eg. /, /ca/, /uk/, etc…

          links = page.all(:css, 'nav #mobile-nav[aria-modal="true"][aria-hidden="true"] a')

          expected_links = [
            # label, path, title

            # Features:
            ["Performance", '/TODO'],
            ["Dividends", '/TODO'],
            ["Tax Reporting", '/TODO'],
            ["Supported Investments", '/TODO'],
            ["Supported Exchanges", localize_url('supported-stock-exchanges-and-managed-funds', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],
            ["Supported Brokers", localize_url('supported_brokers', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],
            ["Pricing", localize_path('pricing', locale_id: locale_obj[:id])], # NOTE: Mobile-only!
            ["Frequently Asked Questions", localize_path('faq', locale_id: locale_obj[:id])],
            ["Data Security", localize_url('how-sharesight-protects-your-data-', locale_id: locale_obj[:id], base_url: Capybara.app.config[:help_url])],

            # Benefits:
            ["Investors", '/TODO'],
            ["Finance Professionals", localize_path('pro', locale_id: locale_obj[:id])],
            ["Finance Companies", localize_path('become-a-partner', locale_id: locale_obj[:id])],

            # Resources:
            ["About Sharesight", localize_path('about-sharesight', locale_id: locale_obj[:id])],
            ["Executive Team", localize_path('team', locale_id: locale_obj[:id])],
            ["Reviews", localize_path('reviews', locale_id: locale_obj[:id])],

            ["Partner Directory", localize_path('partners', locale_id: locale_obj[:id])],
            ["Become a Partner", localize_path('become-a-partner', locale_id: locale_obj[:id])],
            ["Become an Affiliate", localize_path('affiliates', locale_id: locale_obj[:id])],
            ["sales@sharesight.com", 'mailto:sales@sharesight.com'],

            ["Blog", base_url("blog")],
            ["Help Centre", Capybara.app.config[:help_url]],
            ["Sharesight API", Capybara.app.config[:api_url]],
            ["Webinars & Events", localize_path('events', locale_id: locale_obj[:id])],

            ["Log In", Capybara.app.config[:login_url]],
            ["Sign Up", Capybara.app.config[:signup_url]]
          ]

          expect(links.length).to eq(expected_links.length)

          # iterate through all links on the page and find the expectations
          links.each do |link|
            matched_link = expected_links.find do |expected_link|
              link.text.include?(expected_link[0])
            end

            expect(matched_link).to_not(be_nil, "Unexpected link '#{link.text}' in #{expected_links}")

            expected_href = matched_link[1]
            if expected_href
              expect(link[:href]).to(match(expected_href), "Link '#{link.text}' did not match expected href of '#{expected_href}', got #{link[:href]}.")
            end

            expected_links.delete(matched_link)
          end

          expect(expected_links.length).to(eq(0), "Found leftover links in expected_links: #{expected_links}")
        end
      end

      it "pro has a different signup url inside the modal" do
        visit '/pro'

        links = page.all(:css, 'nav #mobile-nav a')

        sign_up = links.find do |link|
          link.text.include?('Sign Up')
        end

        expect(sign_up.text).to include('Sign Up')
        expect(sign_up[:href]).to eq(Capybara.app.config[:pro_signup_url])
      end
    end
  end

end
