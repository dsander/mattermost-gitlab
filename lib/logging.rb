# frozen_string_literal: true

module Logging
  def self.initialize_logger(log_target = STDOUT, log_level = Logger::DEBUG)
    @logger = Logger.new(log_target)
    @logger.level = log_level
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
