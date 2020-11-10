require 'spec_helper'

describe 'Footer', type: :feature do
  it 'should have the correct links' do
    [
      /^Home/,
      /^Executive Team/,
      /^About Us/,
      /^Pricing/,
      /^Reviews/,
      /^Affiliates/,
      /^FAQ/,
      /^Blog/,
      /^Webinars & Events/,
      /^Partners/,
      /^Partner with Us/,
      /^Developer API/,
      /^Privacy Policy/,
      /^Terms of Use/,
      /^Pro Terms of Use/,
      /^Help/,
      /^Community Forum/,
      /^sales@sharesight.com/
    ].each do |text|
      visit '/'
      expect(page.find('a.footer__link', text: text)).to_not be_nil
    end
  end
end
