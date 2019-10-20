# frozen_string_literal: true

class ActionCommand < Command
  include Logging

  REQUIRED_PARAMS = %w[user_id channel_id team_id post_id trigger_id type context].freeze
  REQUIRED_CONTEXT = %w[args response_url token].freeze
  attr_reader(*(REQUIRED_PARAMS + REQUIRED_CONTEXT))

  def initialize(params, token)
    super

    REQUIRED_CONTEXT.each do |p|
      raise MissingParams unless context[p]

      instance_variable_set("@#{p}", context[p])
    end

    raise InvalidToken if token && @token != token
  end
end
