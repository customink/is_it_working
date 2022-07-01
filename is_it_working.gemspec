# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'is_it_working/version'
Gem::Specification.new do |spec|
  spec.name          = 'is_it_working'
  spec.version       = IsItWorking::VERSION.dup  # dup for ruby 1.9
  spec.authors       = ['Brian Durand', 'Milan Dobrota']
  spec.email         = ['mdobrota@tribpub.com']
  spec.summary       = 'Rack handler for monitoring several parts of a web application.'
  spec.description   = 'Rack handler for monitoring several parts of a web application so one request can determine which system or dependencies are down.'
  spec.homepage      = ''

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'actionmailer', '>= 3.2'
  spec.add_development_dependency 'activerecord', '>= 3.2'
  spec.add_development_dependency 'activesupport', '>= 3.2'

  # Dalli requires specific versioning, depending on the version of Ruby
  if ::Gem::Version.new(RUBY_VERSION) <= ::Gem::Version.new("2.3.0")
    spec.add_development_dependency 'bundler', '< 2'
  else
    spec.add_development_dependency 'bundler'
  end

  if ::Gem::Version.new(RUBY_VERSION) <= ::Gem::Version.new("2.5.0")
    spec.add_development_dependency 'dalli', '< 3.0.0'
    spec.add_development_dependency 'sqlite3', '~> 1.3.0'
  else
    spec.add_development_dependency 'dalli', '~> 3'
    spec.add_development_dependency 'sqlite3'
  end


  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rake'     , '~> 13.0'
  spec.add_development_dependency 'appraisal', '~> 2.0'
  spec.add_development_dependency 'net-smtp'
end
