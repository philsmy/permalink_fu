require 'rubygems'
require 'bundler/setup'

require 'permalink_fu'

RSpec.configure do |config|
  config.order = "random"
  config.color_enabled = true
  config.tty = true
end