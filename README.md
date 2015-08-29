# ahtung_template
Template generator for ahtung

## Usage

Below command gets current ruby version using 'ruby -v' and inserts it into newly created Gemfile
    rails new blog --database=postgresql -T -m template.rb

You may need to add below class method to user model
    def self.find_for_google_oauth2(access_token, _ = nil)
      data = access_token.info
      user = User.find_by(email: data['email'])
      unless user
        user = User.create(
          email: data['email'],
          password: Devise.friendly_token[0, 20]
        )
      end
      user
    end