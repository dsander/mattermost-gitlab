# frozen_string_literal: true

class ListUnestimatedJob < BaseJob
  include ActiveSupport::Inflector
  attr_reader :command, :args

  def perform(command)
    @command = command
    @args = command.args

    validate_args || return

    (_, _, issues_without_estimates) = load_issues

    return if issues_without_estimates.empty?

    respond(lines: ["Issues missing estimations:"] + issues_without_estimates)
  rescue StandardError => e
    respond(lines: [e.message] + e.backtrace)
  end
end
