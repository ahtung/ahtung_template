# template.rb
require 'rubygems'
require 'bundler/setup'
require 'erubis'
require 'circleci'
require 'octokit'

# Config
environments = %w(staging production)
templates_path = File.expand_path("../../templates", __FILE__)
envs = {
  google_client_secret: '',
  google_client_id: ''
}

# Ruby
version_string = `ruby -v`
ruby_version = /\d\.\d\.\d/.match(version_string).to_s

# GitHub
git_username = ask('GitHub username?')
git_organization = ask('GitHub organization?')
git_password = ask('GitHub password?')

Octokit.configure do |config|
  config.login = git_username
  config.password = git_password
end

user = Octokit.user
user.login

Octokit.create_repository(@app_name, organization: git_organization)

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

# Foreman Configuration
create_file 'Procfile', 'web: rails s'
create_file 'Procfile.dev', 'web: rails s'
create_file 'Procfile.dev.env'

# Meanwhile create the app on heroku and set the variables
`heroku login`
`heroku create #{@app_name}`
open('Procfile.dev.env', 'a') { |f|
  envs.each do |key, value|
    f << "#{key.upcase}=#{value}\n"
    `heroku config:set #{key.upcase}=#{value} --app #{@app_name}`
  end
}
# Omniauth configuration
copy_file 'templates/omniauth_callbacks_controller.rb', 'app/controllers/users/omniauth_callbacks_controller.rb'
remove_file 'config/initializers/devise.rb'
copy_file 'templates/devise.rb', 'config/initializers/devise.rb'
gsub_file 'config/routes.rb', /:users/, ":users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }"
gsub_file 'app/models/user.rb', /devise :/, 'devise :omniauthable, omniauth_providers: [:google_oauth2], :'

# Git
remove_file '.gitignore'
get "https://raw.githubusercontent.com/github/gitignore/master/Rails.gitignore", ".gitignore"
git :init
git add: '.'
git commit: '-m First commit!'
git remote: "add origin git@github.com:#{git_username}/#{@app_name}.git"
git remote: "add staging git@heroku.com:#{@app_name}-staging.git"
git remote: "add production git@heroku.com:#{@app_name}.git"
git push: 'origin master'