require 'zeitwerk'
require 'sucker_punch'
require 'gitlab'

if ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

Gitlab.configure do |config|
  config.endpoint       = "#{ENV.fetch('GITLAB_HOST')}/api/v4"
  config.private_token  = ENV.fetch('GITLAB_TOKEN')
end

loader = Zeitwerk::Loader.new
loader.push_dir('lib')
loader.setup
loader.eager_load

SuckerPunch.logger = Logging.logger

$stdout.sync = true

run Server.freeze.app
