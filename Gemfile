source "https://rubygems.org"

gemspec

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

group :test do
  gem "parallel", "< 1.20" # remove this pin/dep when we drop ruby < 2.4
  gem "chefstyle", "1.5.2"
  gem "rake"
  gem "rspec", "~> 3.0"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end
