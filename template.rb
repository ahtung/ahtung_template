# template.rb
require 'erubis'

# Ruby
version_string = `ruby -v`
ruby_version = /\d\.\d\.\d/.match(version_string).to_s

# Circle CI
template_path = File.dirname(__FILE__)
copy_file "#{template_path}/circle.yml", 'circle.yml'
environments = %w(staging production)
context = { app_name: @app_name }
environments.each do |environment|
  template = Erubis::Eruby.new(File.read("#{template_path}/script/deploy/#{environment}.erb"))
  create_file "script/deploy/#{environment}", template.evaluate(context)
  FileUtils.chmod "+x", "script/deploy/#{environment}"
end

# remove & recreate GEMFILE
remove_file 'Gemfile'
create_file 'Gemfile', <<-CODE

source 'https://rubygems.org'

ruby '#{ruby_version}'

gem 'rails', '4.2.4'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'puma'
gem 'foreman'
gem 'slim-rails'
gem 'omniauth-google-oauth2'
gem 'sidekiq'
gem 'pundit'
gem 'sitemap_generator'
gem 'meta-tags'
gem 'roboto'
gem 'rubocop'
gem 'factory_girl_rails'
gem 'faker'
group :development do
  gem 'brakeman', require: false
  gem 'better_errors'
end

group :development, :test do
  gem 'pry-remote'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
end

source 'https://rails-assets.org' do

end
CODE

# bundle
run 'bundle install'

# Devise configuration
if yes?('Would you like to install Devise?')
  gem 'devise'
  generate 'devise:install'
  model_name = ask('What would you like the user model to be called? [User]')
  model_name = 'User' if model_name.blank?
  generate 'devise', model_name
end

# Action mailer configuration for development
environment "config.action_mailer.default_url_options = { host: 'http://localhost:3000' }", env: 'development'

# Setup DB
rake 'db:setup'

# Migrate DB
rake 'db:migrate'

# Git
git :init
get "https://github.com/github/gitignore/blob/master/Rails.gitignore", ".gitignore"
git add: '.'
git commit: '-m First commit!'
git remote: "add origin git@github.com:dunyakirkali/#{@app_name}.git"
git remote: "add staging git@heroku.com:#{@app_name}-staging.git"
git remote: "add production git@heroku.com:#{@app_name}.git"
git push: 'origin master'
