require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'
require 'cucumber/rake/task'


GEM = "mixlib-config"
GEM_VERSION = "1.0.0"
AUTHOR = "Opscode, Inc."
EMAIL = "info@opscode.com"
HOMEPAGE = "http://www.opscode.com"
SUMMARY = "A class based config mixin, similar to the one found in Chef."

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", 'NOTICE']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.rdoc Rakefile NOTICE) + Dir.glob("{lib,spec,features}/**/*")
end

task :default => :test

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.step_pattern = 'features/steps/**/*.rb'
  supportdir = 'features/support'
  t.cucumber_opts = "--format pretty -r #{supportdir}"
end

desc "Run the spec and features"
task :test => [ :features, :spec ]