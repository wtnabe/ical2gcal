# -*- mode: ruby -*-

source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
gem 'ri_cal'

gem 'google_calendar', :git => 'https://github.com/northworld/google_calendar'
gem 'launchy'

group :development do
  gem "rspec"
  gem "bundler"
  gem "jeweler"
  if RUBY_VERSION < '1.9'
    gem "ruby-debug"
    gem "rcov", ">= 0"
  else
    gem "debugger"
    gem 'simplecov'
  end
end
