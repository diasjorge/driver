require 'rubygems'

gem 'rspec'
require 'spec'

def current_path
  File.expand_path(File.dirname(__FILE__))
end

require "#{current_path}/../driver"
