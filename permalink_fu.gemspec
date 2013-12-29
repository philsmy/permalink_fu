# encoding: utf-8
require File.expand_path('../lib/permalink_fu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Krzysztof Knapik", "technoweenie"]
  gem.email         = ["knapo@knapo.net"]
  gem.homepage      = "https://github.com/knapo/permalink_fu"
  gem.description   = %q{ActiveRecord plugin for creating permalinks}
  gem.summary       = %q{ActiveRecord plugin for creating permalinks}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "permalink_fu"
  gem.require_paths = ["lib"]
  gem.version       = ::PermalinkFu::VERSION
  
  gem.add_dependency('i18n',          '>= 0.6.1')
  gem.add_dependency('rails',         '>= 3.2.13')
  gem.add_dependency('activerecord',  '>= 3.2.13')
  gem.add_dependency('activesupport', '>= 3.2.13')
end