# -*- encoding: utf-8 -*-

$:.unshift(File.dirname(__FILE__) + "/lib")
require "mixlib/config/version"

Gem::Specification.new do |s|
  s.name = "mixlib-config"
  s.version = Mixlib::Config::VERSION

  s.authors = ["Chef Software, Inc."]
  s.email = "info@chef.io"
  s.files = %w{LICENSE NOTICE} + Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.homepage = "https://github.com/chef/mixlib-config"
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.5"
  s.summary = "A class based configuration library"
  s.description = s.summary
  s.license = "Apache-2.0"

  s.add_dependency "tomlrb"
end
