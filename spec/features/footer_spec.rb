require 'spec_helper'

describe 'Footer', type: :feature do
  it 'should have all expected links' do
    visit '/'
    links = page.all(:css, 'a.footer__link')

    expected_links = [
      # text, href

      # Company:
      ["Home", base_url('/')],
      ["Executive Team", base_url("/team/")],
      ["About Us", base_url("/about-sharesight/")],
      ["FAQ", base_url("/faq/")],
      ["Pricing", base_url("/pricing/")],
      ["Webinars & Events", base_url("/events/")],

      # Company pt2:
      ["Sharesight Pro", base_url("/pro/")],
      ["Become a Partner", base_url("/become-a-partner/")],
      ["Partners", base_url("/partners/")],
      ["Affiliates", base_url("/affiliates/")],
      ["Reviews", base_url("/reviews/")],

      # Resources:
      ["Blog", base_url("/blog/")],
      ["API Documentation", Capybara.app.config[:api_url]],
      ["Privacy Policy", base_url("/privacy-policy/")],
      ["Terms of Use", base_url("/sharesight-terms-of-use/")],
      ["Pro Terms of Use", base_url("/sharesight-professional-terms-of-use/")],

      # Support:
      ["Help", Capybara.app.config[:help_url]],
      ["Community Forum", Capybara.app.config[:community_url]],
      ["sales@sharesight.com", 'mailto:sales@sharesight.com'],

      # locales:
      ["Global", base_url('/')],
      ["Australia", base_url('/au/')],
      ["Canada", base_url('/ca/')],
      ["New Zealand", base_url('/nz/')],
      ["United Kingdom", base_url('/uk/')],
    ]

    expect(links.length).to eq(expected_links.length)

    # iterate through all links on the page and find
    links.each do |link|
      matched_link = expected_links.find do |expected_link|
        link.text.match(expected_link[0])
      end

      expect(matched_link).to_not(be_nil, "Unexpected link '#{link.text}'!")

      expected_href = matched_link[1]
      if expected_href
        expect(link[:href]).to(match(expected_href), "Link '#{link.text}' did not match expected href of '#{expected_href}'.")
      end

      expected_links.delete(matched_link)
    end


    expect(expected_links.length).to(eq(0), "Found leftover links in expected_links: #{expected_links}")
  end
end
