require 'spec_helper'

describe 'Partner Middleman Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  context "partner_url" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_partners_partners().each do |partner|
        expect(@app.partner_url(partner)).to be_kind_of(::String)
      end
    end
  end

  context "partner_path" do
    # This is a proxy to other tested helpers.
    it "should return a string" do
      get_partners_partners().each do |partner|
        expect(@app.partner_path(partner)).to be_kind_of(::String)
      end
    end
  end

  context "partner_slug" do
    it "should work as expected" do
      get_partners_partners().each do |partner|
        expect(@app.partner_slug(partner)).to eq("partners/#{partner[:url_slug]}")
      end
    end
  end

  context "partners_collection" do
    it "should be an array of hashes" do
      data = @app.partners_collection()
      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id)
      end
    end
  end

  context "categories_collection" do
    it "should be an array of hashes" do
      data = @app.categories_collection()
      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id)
      end
    end
  end

  context "partners_categories" do
    it "should be an array of hashes" do
      data = @app.partners_categories()

      expect(data).to be_kind_of(Array)
      data.each do |a|
        expect(a).to include(:id, :name, :path, :description, :count, :set)
      end
    end
  end
end
