# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord-futures/version'

Gem::Specification.new do |gem|
  gem.name          = "activerecord-futures"
  gem.version       = Activerecord::Futures::VERSION
  gem.authors       = ["Leonardo Andres Garcia Crespo"]
  gem.email         = ["leoasis@gmail.com"]
  gem.description   = %q{Save unnecessary round trips to the database}
  gem.summary       = %q{Fetch all queries at once from the database and save round trips. }
  gem.homepage      = "https://github.com/leoasis/activerecord-futures"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activerecord', '~> 3.2.11'
  gem.add_development_dependency 'rspec', '2.13.0'
  gem.add_development_dependency 'rspec-spies'
  gem.add_development_dependency 'mysql2', '>= 0.3.12.b1'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'sqlite3'
end
