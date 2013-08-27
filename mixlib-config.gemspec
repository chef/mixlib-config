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
    "README.rdoc"
  ]
  s.files = [ "LICENSE", "NOTICE", "README.rdoc", "Rakefile" ] + Dir.glob("{lib,spec}/**/*")
  s.homepage = "http://www.opscode.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A class based config mixin, similar to the one found in Chef."

end

