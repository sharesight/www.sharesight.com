require "rake/testtask"

task test: ["test:sanity"]

namespace :test do
  desc "Run all tests"

  Rake::TestTask.new "sanity" do |t|
    t.libs << "test"
    t.test_files = Dir.glob("test/**/*_test.rb")
    t.verbose = true
    t.warning = false
  end

end

task default: :test
