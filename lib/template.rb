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
copy_file "#{templates_path}/Gemfile", "Gemfile"
gsub_file "Gemfile", /ruby_version/, "#{ruby_version}"

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
