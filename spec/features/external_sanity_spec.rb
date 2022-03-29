require 'spec_helper'

describe 'External Link Sanity', type: :feature do
  it 'should return a valid page for hard coded links' do
    [
      'reviews',
    ].each do |path|
      visit path
      expect(page).to respond_successfully
    end
  end
end
