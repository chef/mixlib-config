# -*- encoding: utf-8 -*-

$:.unshift(File.dirname(__FILE__) + "/lib")
require "mixlib/config/version"

Gem::Specification.new do |s|
  s.name = "mixlib-config"
  s.version = Mixlib::Config::VERSION

  s.authors = ["Chef Software, Inc."]
  s.email = "legal@chef.io"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md",
  ]
  s.files = ["LICENSE", "NOTICE", "README.md", "Gemfile", "Rakefile"] + Dir.glob("*.gemspec") +
    Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.homepage = "https://www.chef.io"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.required_ruby_version = ">= 2.2"
  s.summary = "A class based configuration library"
  s.description = s.summary
  s.license = "Apache-2.0"

  s.add_dependency "tomlrb"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "chefstyle"
  s.add_development_dependency "rdoc"
end
