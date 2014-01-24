# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'activerecord-dynamic'
  s.version     = '0.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Lin Cheng']
  s.email       = 'darren@thanx.com'
  s.homepage    = 'https://github.com/darrenli/activerecord-dynamic'
  s.summary     = 'ActiveRecord::Dynamic'
  s.description = 'Programmatically specify table names for easy '\
                  'ActiveRecord::Base sharding'
  s.license     = 'MIT'

  s.files       = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_paths = ['lib']
end
