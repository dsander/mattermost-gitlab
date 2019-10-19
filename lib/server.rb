require 'roda'
require "rack/attack"

class Server < Roda
  use Rack::Attack
  include Logging

  plugin :json
  plugin :json_parser

  route do |r|
    r.root do
      <<~EOR
      <p>
      Mattermost slash command handler to summarize issue time estimates based on GitLab issue dashboard link
      </p>

      <p>
      Create a slash command and configure "#{r.env['rack.url_scheme']}://#{r.env['HTTP_HOST']}/api/slash/estimates" as the request URL.
      </p>
      EOR
    end

    r.on 'api' do
      r.on 'slash' do
        r.post 'estimates' do
          cmd = SlashCommand.new(r.params, ENV['ESTIMATES_TOKEN'])
          EstimatesJob.perform_async(cmd)
          ""
        rescue SlashCommand::InvalidToken
          response.status = 403
        rescue SlashCommand::MissingParams
          response.status = 422
        end
      end
    end
  end
end
