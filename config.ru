require_relative './boot'

$stdout.sync = true

run Server.freeze.app
