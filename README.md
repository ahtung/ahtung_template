# ahtung_template
Template generator for ahtung

## Requires

- Heroku
- Postgres

## Usage

Below command gets current ruby version using `ruby -v` and inserts it into the newly created Gemfile

    rails new blog --database=postgresql -T -m https://raw.githubusercontent.com/ahtung/ahtung_template/master/lib/template.rb
