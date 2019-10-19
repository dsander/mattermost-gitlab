# frozen_string_literal: true

require_relative './boot'

$stdout.sync = true

run Server.freeze.app
