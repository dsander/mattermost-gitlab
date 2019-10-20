# frozen_string_literal: true

class SlashCommand < Command
  include Logging

  REQUIRED_PARAMS = %w[channel_id channel_name command response_url team_domain team_id text token trigger_id user_id user_name].freeze
  attr_reader(*REQUIRED_PARAMS)

  def initialize(params, token)
    @token = token

    super

    raise InvalidToken if token && @token != token
  end
end
