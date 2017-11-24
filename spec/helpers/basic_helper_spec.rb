require 'spec_helper'

describe 'Basic Helper', :type => :helper do
  context "replace quotes" do
    it "should remove double quotes" do
      expect("").to            eq(BasicHelper::replace_quotes(""))
      expect("'").to           eq(BasicHelper::replace_quotes('"'))
      expect("normal").to      eq(BasicHelper::replace_quotes('normal'))
      expect("normal'").to     eq(BasicHelper::replace_quotes('normal"'))
      expect("'foo' bar").to   eq(BasicHelper::replace_quotes('"foo" bar'))

      expect('"').not_to           eq(BasicHelper::replace_quotes('"'))
      expect('"').not_to           eq(BasicHelper::replace_quotes(''))
      expect("'").not_to           eq(BasicHelper::replace_quotes(''))
      expect("'foo\" bar").not_to  eq(BasicHelper::replace_quotes('"foo" bar'))
    end
  end

  context "url friendly string" do
    it "should convert to a url friendly string" do
      expect('').to               eq(BasicHelper::url_friendly_string(""))
      expect('-').to              eq(BasicHelper::url_friendly_string(" "))
      expect('foo--bar--baz').to  eq(BasicHelper::url_friendly_string("Foo -& -Bar-- Baz"))
      expect('foo-bar-baz').to    eq(BasicHelper::url_friendly_string("Foo&-Bar-Baz"))
    end
  end
end
