require 'spec_helper'

# NOTE: Really can't use actual content here as they can be invalid (eg. drafts).

describe 'Partner Helper', :type => :helper do
  context "valid partner" do
    it "should be valid" do
      [
        OpenStruct.new({ name: ' foo ', url_slug: 'foo' }),
        OpenStruct.new({ name: 'string', url_slug: 'foo-bar' }),
        OpenStruct.new({ name: 'string', url_slug: '~/#.af3anything$https://' })
      ].each do |obj|
        expect(PartnerHelper.is_valid_partner?(obj)).to be(true), "#{obj.name} was invalid."
      end
    end

    it "should be invalid" do
      [
        OpenStruct.new({ name: ' ', url_slug: ' ' }),
        OpenStruct.new({ name: true, url_slug: false }),
        OpenStruct.new({ id: '123' }),
        OpenStruct.new({ name: 'string', url_slug: false }),
        OpenStruct.new({ categories: [] })
      ].each do |obj|
        expect(PartnerHelper.is_valid_partner?(obj)).to be(false)
      end
    end
  end

  context "valid category" do
    it "should be valid" do
      [
        OpenStruct.new({ name: 'string', url_slug: 'string' }),
        OpenStruct.new({ name: 'string', url_slug: '~/#.af3anything$https://' })
      ].each do |obj|
        expect(PartnerHelper.is_valid_category?(obj)).to be(true)
      end
    end

    it "should be invalid" do
      [
        OpenStruct.new({ name: ' ', url_slug: 'string' }),
        OpenStruct.new({ id: '123' }),
        OpenStruct.new({ title: 'string' }),
        OpenStruct.new({ categories: [] })
      ].each do |obj|
        expect(PartnerHelper.is_valid_category?(obj)).to be(false)
      end
    end
  end

  context "sort_partners" do
    it "should sort by priority" do
      expect(
        [
          { priority: 3, name: 'b' },
          { priority: 1200, name: 'a' },
          { name: 'C' },
          { priority: 5, name: 'a' },
          { priority: 20, name: 'c' },
          { priority: nil, name: 'b' },
          { name: 'a' },
          { priority: 5, name: 'C' }
        ].sort{ |a, b| PartnerHelper.sort_partners(a, b) }
      ).to match_array([
        { priority: 1200, name: 'a' },
        { priority: 20, name: 'c' },
        { priority: 5, name: 'a' },
        { priority: 5, name: 'C' },
        { priority: 3, name: 'b' },
        { name: 'a' },
        { priority: nil, name: 'b' },
        { name: 'C' }
      ])
    end

    it "should sort by name when priority is equal" do
      expect(
        [
          { priority: nil, name: 'ba' },
          { priority: 1, name: 'B' },
          { priority: 2, name: 'A' },
          { name: 'bb' },
          { priority: 2, name: 'aA' },
          { priority: nil, name: 'c' },
          { priority: 1, name: 'a' },
          { priority: 1, name: 'ab' },
          { name: 'a' },
        ].sort{ |a, b| PartnerHelper.sort_partners(a, b) }
      ).to match_array([
        { priority: 2, name: 'A' },
        { priority: 2, name: 'aA' },
        { priority: 1, name: 'a' },
        { priority: 1, name: 'ab' },
        { priority: 1, name: 'B' },
        { name: 'a' },
        { priority: nil, name: 'ba' },
        { name: 'bb' },
        { priority: nil, name: 'c' },
      ])
    end
  end
end
