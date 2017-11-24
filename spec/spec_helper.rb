$LOAD_PATH << File.expand_path('../source', __FILE__)

require 'bundler'
# Pull in all of the gems including those in the `test` group
Bundler.require :default, :test, :development, :debug

# load helpers (from middleman)
Dir[File.join(File.dirname(__FILE__), '..', 'helpers', '**', '*.rb')].each{ |file| require_relative file }

# load all support files
Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each{ |file| require_relative file }
