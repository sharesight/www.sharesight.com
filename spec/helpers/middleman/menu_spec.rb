require 'spec_helper'

describe 'Menu Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  before :each do
    visit '/'
  end

  #######
  #
  # 👉 FYI
  # The actual content is tested in more of a UI/DOM test in `header_spec.rb`.
  #
  #######

  context "get_menu_config" do
    it "should be an array with an expected number of rows, columns, and links" do
      menus = @app.get_menu_config
      expect(menus).to be_kind_of(::Array)
      expect(menus.length).to eq(4)

      rows_length = 0
      columns_length = 0
      links_length = 0
      menus.each do |menu|
        if menu[:rows]
          rows_length += menu[:rows].length
          menu[:rows].each do |row|
            if row[:columns]
              columns_length += row[:columns].length
              row[:columns].each do |column|
                if column[:links]
                  links_length += column[:links].length
                end
              end
            end
          end
        end
      end

      # These are just hardcoded values.
      expect(rows_length).to eq(5)
      expect(columns_length).to eq(8)
      expect(links_length).to eq(23)
    end

    it "should have a partial for blogs in place of a column" do
      menus = @app.get_menu_config()
      resources = menus[3]

      expect(resources[:rows][1]).to eq({ visible_mobile: false, partial: 'partials/header/blog' })
    end

    it "should have expected top-level menu labels" do
      menus = @app.get_menu_config()

      expect(menus[0][:label]).to eq('Features')
      expect(menus[1][:label]).to eq('Benefits')
      expect(menus[2][:label]).to eq('Pricing')
      expect(menus[3][:label]).to eq('Resources')
    end

    # NOTE: This does also test global, because it has no "path" or "country" differences.
    Capybara.app.data.locales.each do |locale_obj|
      it "#{locale_obj[:country]} should have an expected pricing link" do
        # NOTE: We test global above.
        menus = @app.get_menu_config(locale_obj: locale_obj)

        pricing = menus[2]
        expect(pricing[:label]).to eq('Pricing')
        expect(pricing[:title]).to eq("Pricing | Sharesight #{locale_obj[:country]}".strip)
        expect(pricing[:href]).to match(%r{#{locale_obj[:path]}pricing\/$})
      end
    end
  end
end
