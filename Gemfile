source 'http://rubygems.org'

# Specify your gem's dependencies in activerecord-futures.gemspec
gemspec

group :test do
  gem 'rake'
end

gem 'coveralls', require: false

if ENV['activerecord']
  gem "activerecord", ENV['activerecord']
end
