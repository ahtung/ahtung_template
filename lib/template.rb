# template.rb
require 'rubygems'
require 'bundler/setup'
require 'erubis'
require 'circleci'

# Config
environments = %w(staging production)
templates_path = File.expand_path("../../templates", __FILE__)

# Ruby
version_string = `ruby -v`
ruby_version = /\d\.\d\.\d/.match(version_string).to_s

# GitHub
git_username = ask('GitHub username?')

# Circle CI
token = ask('Circle CI token?')
if token
  # Config circleci
  CircleCi.configure do |config|
    config.token = token
  end
  res = CircleCi::User.me
  if res.success?
    # Enable project
    res = CircleCi::Project.enable git_username, @app_name
    if res.success?
      puts "Successfully enabled CircleCi for #{@app_name}"
    else
      puts "Could not enable CircleCi for #{@app_name}"
    end

    copy_file "#{templates_path}/circle.yml", 'circle.yml'
    context = { app_name: @app_name }
    environments.each do |environment|
      template = Erubis::Eruby.new(File.read("#{templates_path}/script/deploy/#{environment}.erb"))
      create_file "script/deploy/#{environment}", template.evaluate(context)
      FileUtils.chmod "+x", "script/deploy/#{environment}"
    end
  end
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
gem "puma"
gem "foreman"
gem "slim-rails"
gem "devise"
gem "omniauth-google-oauth2"
gem "sidekiq"
gem "pundit"
gem "sitemap_generator"
gem "meta-tags"
gem "roboto"
gem "rubocop"
gem "factory_girl_rails"
gem "faker"
group :development do
  gem "brakeman", require: false
  gem "better_errors"
end

group :development, :test do
  gem "pry-remote"
  gem "rspec-rails"
  gem "capybara"
  gem "launchy"
  gem "database_cleaner"
  gem "selenium-webdriver"
end

group :test do
  gem "shoulda-matchers", require: false
  gem "simplecov", require: false
end

source 'https://rails-assets.org' do

end
CODE

# bundle
run 'bundle install'

# Setup DB
rake 'db:setup'

# Migrate DB
rake 'db:migrate'
