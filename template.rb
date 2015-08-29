# template.rb

# GEMS
gem 'puma'
gem 'foreman'
gem 'slim-rails'
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'sidekiq'
gem 'pundit'
gem 'sitemap_generator'
gem 'meta-tags'
gem 'roboto'
gem 'rubocop'
gem 'factory_girl_rails'
gem 'faker'

# Development gems
gem_group :development do
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'better_errors'
end

# Development & Test gems
gem_group :development, :test do
  gem 'pry-remote'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

gem_group :test do
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
end

# Rails assets source
add_source 'https://rails-assets.org'
