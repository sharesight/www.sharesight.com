# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: "bundle exec rspec --fail-fast" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  watch(%r{^helpers/(.+)\.rb$})             { |m| "spec/helpers/#{m[1]}_spec.rb" }
  watch(%r{^data/(.+)\.json$})              { "spec" }
  watch('config.rb.rb')                     { "spec" }
  watch('spec/spec_helper.rb')              { "spec" }
end
