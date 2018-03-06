RSpec.configure do |config|
  config.before(:all) do
    # start with a current_path (and other global variables) in middleman
    visit '/'
  end
end

RSpec::Matchers.define :respond_successfully do
  match do |page|
    expect(page.status_code).to be_between(200, 399).inclusive
  end

  failure_message do |page|
    "Could not load #{current_path}, got a #{page.status_code} response."
  end
end

RSpec::Matchers.define :have_img do |src|
  match do |page|
    expect(page).to have_xpath("//img[contains(@src,\"#{src}\")]")
  end

  failure_message do |actual|
    "expected to have img #{src} on #{current_path}"
  end
end

RSpec::Matchers.define :have_base_metas do
  match do |page|
    expect(page).to have_meta('utf-8', name_key: 'charset')
    expect(page).to have_meta('viewport')
    expect(page).to have_meta('robots')
    expect(page).to have_meta('application-name', 'Sharesight')
  end

  failure_message do |actual|
    "expected to have base metas (charset, viewport, etc) on #{current_path}"
  end
end

RSpec::Matchers.define :have_social_metas do
  match do |page|
    expect(page).to have_meta('twitter:site:id', '109123696')
    expect(page).to have_meta('twitter:card', 'summary_large_image')
    expect(page).to have_meta('twitter:site', '@sharesight')
    expect(page).to have_meta('fb:app_id', '1028405463915894', name_key: 'property')
    expect(page).to have_meta('og:site_name', 'Sharesight', name_key: 'property')

    expect(page).to have_meta('og:image', name_key: 'property')

    og_image_value = get_meta('og:image', name_key: 'property')
    is_local_image = og_image_value.start_with?(Capybara.app.config[:base_url])

    expect(og_image_value).to start_with('https://') if !is_local_image

    if is_local_image
      expect(page).to have_meta('og:image:type', name_key: 'property')
      expect(page).to have_meta('og:image:width', name_key: 'property')
      expect(page).to have_meta('og:image:height', name_key: 'property')
    end

    true # must return true as `expect() if false` would return nil and returning a nil fails a matcher
  end

  failure_message do |actual|
    "expected to have social metas (twitter:site:id, og:site_name, og:image:*, etc) on #{current_path}"
  end
end

RSpec::Matchers.define :have_titles do |title, social_title|
  social_title ||= Capybara.app.generate_social_title(title)
  match do |page|
    # Titles can be a bit weird with spacing; HTML seems to squeeze, but Capybara won't..
    expect(page.title).to                                   eq(title)
    expect(get_meta('og:title', name_key: 'property')).to   eq(social_title)
  end

  failure_message do |page|
    "expected <title>#{page.title}</title> to match #{title}/#{social_title} on #{current_path}"
  end
end

RSpec::Matchers.define :have_descriptions do |description, social_description|
  social_description ||= description
  match do |page|
    expect(page).to have_meta('description', description)
    expect(page).to have_meta('og:description', social_description, name_key: 'property')
  end

  failure_message do |actual|
    "expected to have descriptions of #{description} and #{social_description} on #{current_path}"
  end
end

RSpec::Matchers.define :have_meta do |name, content = nil, name_key: 'name', debug: :content|
  match do |page|
    args = { name_key => name }
    args[:content] = content if content

    expect(page).to have_head('meta', args: args, debug: debug)
  end
end

RSpec::Matchers.define :have_head do |tagname, args: {}, contains: {}, ends_with: {}, starts_with: {}, debug: nil|
  match do |page|
    xpath = generate_xpath("//html/head/#{tagname}", args: args, contains: contains, ends_with: ends_with, starts_with: starts_with)

    expect(page).to have_xpath(xpath, visible: false)
  end

  failure_message do |actual|
    if !debug.nil?
      expectation = args[debug] || contains[debug] || ends_with[debug] || starts_with[debug]
      actual = get_head(tagname, args: args, contains: contains, ends_with: ends_with, starts_with: starts_with, return_key: debug)
      return "No head.#{tagname} matching #{debug} found. Expected: #{expectation}; actual: #{actual} on #{current_path}"
    end
  end
end
