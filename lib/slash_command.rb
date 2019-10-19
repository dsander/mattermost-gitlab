class SlashCommand
  include Logging

  REQUIRED_PARAMS = %w[channel_id channel_name command response_url team_domain team_id text token trigger_id user_id user_name]
  attr_reader *REQUIRED_PARAMS

  class InvalidToken < StandardError; end
  class MissingParams < StandardError; end

  def initialize(params, token)
    @token = token
    logger.warn "Not validating slash command because token is missing" unless token
    REQUIRED_PARAMS.each do |p|
      raise MissingParams unless params[p]
      instance_variable_set("@#{p}", params[p])
    end
    raise InvalidToken if token && @token != token
  end

  def respond(lines:, response_type: 'ephemeral', icon: nil, username:)
    res = HTTParty.post @response_url,
                        body: JSON.dump({text: lines.join("\n"), response_type: response_type, icon_url: icon, username: username}),
                        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
    logger.error "Unable to post response to Mattermost: #{res}" if res.code != 200
  end
end
