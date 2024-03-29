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
      expect(rows_length).to eq(4)
      expect(columns_length).to eq(8)
      expect(links_length).to eq(24)
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
        expect(pricing[:title]).to match(/Pricing | Sharesight(\s\w+)?/)
        expect(pricing[:href]).to match(%r{#{locale_obj[:path]}pricing\/$})
      end

      [
        ['About Sharesight', 'About Us'], # page from codebase
        ['Data Security', 'Data Security'], # manually
        ['Become a Partner', 'Partner with Sharesight'], # page from Contentful. NOTE: This may change!
        ['Sharesight Blog', 'Read the Sharesight Blog', true], # hardcoded title, no localization
        ['Sharesight API', 'Sharesight API Documentation', true], # hardcoded title, no localization
      ].each do |label, title, ignore_localization|
        it "#{locale_obj[:country]} should have an an expected, localized title for #{label}" do
          # NOTE: We test global above.
          menus = @app.get_menu_config(locale_obj: locale_obj)

          link = find_menu_link(menus, label)
          raise "Could not find label: #{label} in #{locale_obj[:country]}!" unless link

          title_localized = if ignore_localization
            title
          else
            "#{title} | #{locale_obj[:append_title]}"
          end

          expect(link[:label]).to eq(label)
          expect(link[:title]).to eq(title_localized)
        end
      end
    end
  end

  private

  def find_menu_link(menus, label)
    menus.each do |menu|
      next unless menu[:rows]

      menu[:rows].each do |row|
        next unless row[:columns]

        row[:columns].each do |column|
          next unless column[:links]

          column[:links].each do |link|
            return link if link[:label] == label
            return link if link[:label].blank? && link[:title] == label
          end
        end
      end
    end
  end
end
