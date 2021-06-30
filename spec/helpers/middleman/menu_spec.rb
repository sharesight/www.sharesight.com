require 'spec_helper'

describe 'Menu Helper', type: :helper do
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

  context 'get_menu_config' do
    it 'should be an array with an expected number of rows, columns, and links' do
      menus = @app.get_menu_config
      expect(menus).to be_kind_of(::Array)
      expect(menus.length).to eq(4)

      rows_length = 0
      columns_length = 0
      links_length = 0
      menus.each do |menu|
        next unless menu[:rows]

        rows_length += menu[:rows].length
        menu[:rows].each do |row|
          next unless row[:columns]

          columns_length += row[:columns].length
          row[:columns].each do |column|
            links_length += column[:links].length if column[:links]
          end
        end
      end

      # These are just hardcoded values.
      expect(rows_length).to eq(5)
      expect(columns_length).to eq(8)
      expect(links_length).to eq(24)
    end

    it 'should have a partial for blogs in place of a column' do
      menus = @app.get_menu_config
      resources = menus[3]

      expect(resources[:rows][1]).to eq({ visible_mobile: false, partial: 'partials/header/blog' })
    end

    it 'should have expected top-level menu labels' do
      menus = @app.get_menu_config

      expect(menus[0][:label]).to eq('Features')
      expect(menus[1][:label]).to eq('Benefits')
      expect(menus[2][:label]).to eq('Pricing')
      expect(menus[3][:label]).to eq('Resources')
    end

    it 'should have a different link when professional=true' do
      menus = @app.get_menu_config
      menus_pro = @app.get_menu_config(professional: true)

      ####
      # Desktop Item
      regular_menu = menus[2]
      pro_menu = menus_pro[2]
      expect(regular_menu[:label]).to eq('Pricing')
      expect(regular_menu[:visible_mobile]).to eq(false)
      expect(pro_menu[:label]).to eq('Pricing')
      expect(pro_menu[:visible_mobile]).to eq(false)

      # Labels are as expected
      expect(regular_menu[:href]).to end_with('/pricing/')
      expect(pro_menu[:href]).to eq('#pricing')
      expect(pro_menu[:href]).not_to eq(regular_menu[:href]) # don't match
      # End Desktop
      ####

      ####
      # Mobile Item
      regular_menu = menus[0][:rows][1][:columns][0][:links][0]
      pro_menu = menus_pro[0][:rows][1][:columns][0][:links][0]
      expect(regular_menu[:label]).to eq('Pricing')
      expect(regular_menu[:visible_desktop]).to eq(false)
      expect(pro_menu[:label]).to eq('Pricing')
      expect(pro_menu[:visible_desktop]).to eq(false)

      # Labels are as expected
      expect(regular_menu[:href]).to end_with('/pricing/')
      expect(pro_menu[:href]).to eq('#pricing')
      expect(pro_menu[:href]).not_to eq(regular_menu[:href]) # don't match
      # End Desktop
      ####
    end

    # NOTE: This does also test global, because it has no "path" or "country" differences.
    Capybara.app.data.locales.each do |locale_obj|
      it "#{locale_obj[:country]} should have an expected pricing link" do
        # NOTE: We test global above.
        menus = @app.get_menu_config(locale_obj: locale_obj)

        pricing = menus[2]
        expect(pricing[:label]).to eq('Pricing')
        expect(pricing[:title]).to eq("Pricing | Sharesight #{locale_obj[:country]}".strip)
        expect(pricing[:href]).to match(%r{#{locale_obj[:path]}pricing/$})
      end

      [
        ['About Sharesight', 'About Us'], # page from codebase
        ['Data Security', 'Data Security'], # manually
        ['Become a Partner', 'Partner with Sharesight'], # page from Contentful. NOTE: This may change!
        ['Sharesight Blog', 'Read the Sharesight Blog', true], # hardcoded title, no localization
        ['Sharesight API', 'Sharesight API Documentation', true] # hardcoded title, no localization
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
