# template.rb

# README

# GEMS
gem 'puma'
gem 'foreman'
gem 'slim-rails'
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'sidekiq'
gem 'pundit'
gem 'sitemap_generator'
gem 'rubocop'
gem 'factory_girl_rails'

gem_group :development do
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'better_errors'
end

gem_group :development, :test do
  gem 'byebug'
  gem 'pry-remote'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

gem_group :test do
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
end

add_source 'https://rails-assets.org'
