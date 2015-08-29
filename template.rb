# template.rb

# ask for ruby version
version_string = `ruby -v`
ruby_version = /\d\.\d\.\d/.match(version_string).to_s

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

# Omniauth configuration
copy_file 'templates/omniauth_callbacks_controller.rb', 'app/controllers/users/omniauth_callbacks_controller.rb'
remove_file 'config/initializers/devise.rb'
copy_file 'templates/devise.rb', 'config/initializers/devise.rb'

gsub_file 'config/routes.rb', /:users/, ":users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }"
gsub_file 'app/models/user.rb', /devise :/, 'devise :omniauthable, omniauth_providers: [:google_oauth2], :'