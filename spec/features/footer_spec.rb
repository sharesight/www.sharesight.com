require 'spec_helper'

describe 'Footer', type: :feature do
  it 'should have all expected links' do
    visit '/'
    links = page.all(:css, 'a.footer__link')

    expected_links = [
      # text, href

      # Sharesight:
      ["Home", base_url('/')],
      ["Executive Team", base_url("/team/")],
      ["About Us", base_url("/about-sharesight/")],
      ["FAQ", base_url("/faq/")],
      ["Pricing", base_url("/pricing/")],
      ["Reviews", base_url("/reviews/")],

      # Partners:
      ["Sharesight Pro", base_url("/pro/")],
      ["Partner Directory", base_url("/partners/")],
      ["Become a Partner", base_url("/become-a-partner/")],
      ["Become an Affiliate", base_url("/affiliates/")],
      ["Sharesight API", Capybara.app.config[:api_url]],
      ["sales@sharesight.com", 'mailto:sales@sharesight.com'],

      # Resources:
      ["Help Centre", Capybara.app.config[:help_url]],
      ["Blog", base_url("/blog/")],
      ["Webinars & Events", base_url("/events/")],
      ["Privacy Policy", base_url("/privacy-policy/")],
      ["Terms of Use", base_url("/sharesight-terms-of-use/")],
      ["Pro Terms of Use", base_url("/sharesight-professional-terms-of-use/")],

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
