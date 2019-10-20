# frozen_string_literal: true

class Command
  include Logging

  class InvalidToken < StandardError; end
  class MissingParams < StandardError; end

  def initialize(params, token)
    @token = token
    logger.warn "Not validating slash command because token is missing" unless token
    required_params.each do |p|
      raise MissingParams unless params[p]

      instance_variable_set("@#{p}", params[p])
    end
  end

  def required_params
    self.class.const_get(:REQUIRED_PARAMS)
  end

  def respond(lines:, response_type: 'ephemeral', icon: nil, username:, attachments: [])
    res = HTTParty.post @response_url,
                        body: JSON.dump(text: lines.join("\n"), response_type: response_type, icon_url: icon, username: username, attachments: attachments),
                        headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    logger.error "Unable to post response to Mattermost: #{res}" if res.code != 200
  end
end
