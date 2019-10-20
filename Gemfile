# frozen_string_literal: true

ruby ">=2.6"

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
gem 'gitlab'
gem 'rack'
gem 'rack-attack'
gem 'roda'
gem 'puma'
gem 'zeitwerk'
gem 'sucker_punch'

group :development, :test do
  gem 'dotenv'
  gem 'rspec', require: false
  gem 'rack-test', require: false
  gem 'rerun', require: false
  gem 'simplecov', require: false
  gem 'webmock', require: false
  gem 'solargraph'
  gem 'pronto-simplecov'
end

group :lint do
  gem 'rubocop'
  gem 'pronto'
  gem 'pronto-rubocop'
end
