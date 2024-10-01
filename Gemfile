source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1"

gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "jsbundling-rails"
gem "turbo-rails", "~> 2.0.3"
gem "stimulus-rails", "~> 1.0", ">= 1.0.2"
gem "cssbundling-rails"
gem "jbuilder"

# gem "kredis"
# gem "sassc-rails"
# gem "image_processing", "~> 1.2"

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "better_errors"
  gem "binding_of_caller"

  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

end

gem 'dotenv-rails', groups: [:development, :test]

gem "devise"
gem 'httparty'
gem 'kaminari'
gem "platform_agent"

gem 'font-awesome-sass', '~> 6.4.0'

gem "aws-sdk-s3", require: false
gem 'redis'