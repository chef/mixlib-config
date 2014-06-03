# -*- encoding: utf-8 -*-

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'mixlib/config/version'


Gem::Specification.new do |s|
  s.name = "mixlib-config"
  s.version = Mixlib::Config::VERSION

  s.authors = ["Opscode, Inc."]
  s.email = "info@opscode.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [ "LICENSE", "NOTICE", "README.md", "Rakefile" ] + Dir.glob("{lib,spec}/**/*")
  s.homepage = "http://www.opscode.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A class based configuration library"
  s.description = s.summary

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.99'
  s.add_development_dependency 'rdoc'
end
