# frozen_string_literal: true

require 'logger'

module Logging
  def self.initialize_logger(log_target = STDOUT, log_level = Logger::INFO)
    @logger = Logger.new(log_target)
    @logger.level = ENV["RACK_ENV"] == 'development' ? Logger::DEBUG : log_level
    @logger
  end

  def self.logger
    defined?(@logger) ? @logger : initialize_logger
  end

  def self.logger=(log)
    @logger = (log || Logger.new('/dev/null'))
  end

  def logger
    Logging.logger
  end
end
