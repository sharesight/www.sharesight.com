require 'spec_helper'

describe 'Helper', :type => :helper do
  before :all do
    @app = Capybara.app
  end

  before :each do
    visit '/'
  end

  context "default_locale_id" do
    it "should match global" do
      expect(@app.default_locale_id).to eq('global')
    end
  end

  context "default_locale_obj" do
    it "should have an id of global" do
      expect(@app.default_locale_obj[:id]).to eq('global')
    end
  end

  context "current_locale (id and obj)" do
    it "should have an id matching the path" do
      locales.each do |locale|
        visit locale[:path]
        expect(@app.current_locale_id).to eq(locale[:id])
        expect(@app.current_locale_obj[:id]).to eq(locale[:id])
      end
    end
  end

  context "is_current_locale_id?" do
    it "should be the current locale at the path" do
      locales.each_with_index do |locale, index|
        other_locale = locales[index + (index + 1 < locales.length ? 1 : -1)]
        visit locale[:path]
        expect(@app.is_current_locale_id?(locale[:id])).to be true
        expect(@app.is_current_locale_id?(other_locale[:id])).to be false
      end
    end
  end

  context "get_locale_obj" do
    it "should have an id matching the locale" do
      locales.each do |locale|
        expect(@app.get_locale_obj(locale[:id])[:id]).to eq(locale[:id])

        visit locale[:path]
        expect(@app.get_locale_obj[:id]).to eq(locale[:id])
      end
    end
  end

  context "is_valid_locale_id?" do
    it "should give the correct response" do
      locales.each do |locale|
        expect(@app.is_valid_locale_id?(locale[:id])).to be true
      end

      expect(@app.is_valid_locale_id?(nil)).to be false
      expect(@app.is_valid_locale_id?('')).to be false
      expect(@app.is_valid_locale_id?('gb')).to be false
      expect(@app.is_valid_locale_id?('ug')).to be false
      expect(@app.is_valid_locale_id?('foo')).to be false
    end
  end

  context "locale_cert_type" do
    it "should give the correct response" do
      visit '/'
      expect(@app.locale_cert_type).to eq('stock')

      visit '/au'
      expect(@app.locale_cert_type).to eq('share')

      locales.each do |locale|
        visit locale.path
        expect(@app.locale_cert_type).to eq(locale[:cert_type]), "Wrong locale_cert_type at #{locale[:path]}; expected #{locale[:cert_type]}, got #{@app.locale_cert_type}"
      end
    end
  end

  context "locale_plans" do
    # test coverage here isn't 100%!
    it "should give proper values for all plans and locales" do
      locales.each do |locale|
        plans = @app.locale_plans(locale[:id])

        expect(plans.length).to eq(4)

        ['free', 'starter', 'investor', 'expert'].each do |plan_label|
          plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
          expect(plan).to be_truthy, "Could not find #{plan_label} plan on #{locale[:id]}"

          expect(plan.price).to be_kind_of(::Integer)
          expect(plan.portfolios).to be_truthy
          expect(plan.holdings).to be_truthy
          expect(plan.custom_groups).to be_truthy

          expect(plan.features).to be_kind_of(::Hash)
          expect(plan.reports).to be_kind_of(::Hash)
          expect(plan.info).to be_kind_of(::Array)

          expect(plan.reports.performance_report).to eq(true)
          expect(plan.reports.taxable_income_report).to eq(true)
          expect(plan.reports.historical_cost_report).to eq(true)
          expect(plan.reports.sold_securities_report).to eq(true)

          expect(plan.reports.traders_tax_report).to eq(false) unless locale[:id] == 'nz'
        end
      end
    end

    it "should have a free and paid plans on all locales" do
      locales.each do |locale|
        plans = @app.locale_plans(locale[:id])

        plan = plans.find{ |plan| plan[:label]&.downcase == 'free' }
        expect(plan.price).to eq(0)

        ['starter', 'investor', 'expert'].each do |plan_label|
          plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
          expect(plan.price).to be > 0, "No price for #{plan_label} plan on #{locale[:id]}"
        end
      end
    end

    it "should give custom pricing for au plans" do
      plans = @app.locale_plans('au')
      expect(plans.length).to eq(4)

      plan_label = 'starter'
      plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
      expect(plan.price).to eq(15)

      plan_label = 'investor'
      plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
      expect(plan.price).to eq(25)

      plan_label = 'expert'
      plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
      expect(plan.price).to eq(39)
    end

    it "should give custom reports for au plans" do
      plans = @app.locale_plans('au')
      expect(plans.length).to eq(4)

      ['free', 'starter'].each do |plan_label|
        plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
        expect(plan.reports.capital_gains_tax_report).to eq(true)
      end

      ['investor', 'expert'].each do |plan_label|
        plan = plans.find{ |plan| plan[:label]&.downcase == plan_label }
        expect(plan.reports.capital_gains_tax_report).to eq(true)
        expect(plan.reports.unrealised_capital_gains_tax_report).to eq(true)
      end
    end
  end
end
