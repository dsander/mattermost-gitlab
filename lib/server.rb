# frozen_string_literal: true

class Server < Roda
  use Rack::Attack
  include Logging

  plugin :json
  plugin :json_parser

  def hostname(req)
    ENV.fetch("DOMAIN", "#{req.env['rack.url_scheme']}://#{req.env['HTTP_HOST']}")
  end

  route do |r|
    r.root do
      <<~TEMPLATE
        <p>
        Mattermost slash command handler to summarize issue time estimates based on GitLab issue dashboard link
        </p>

        <p>
        Create a slash command and configure "#{hostname(r)}/api/slash/estimates" as the request URL.
        </p>
      TEMPLATE
    end

    r.on 'api' do
      r.on 'slash' do
        r.post 'estimates' do
          cmd = SlashCommand.new(r.params, ENV['ESTIMATES_TOKEN'])
          EstimatesJob.perform_async(cmd, hostname(r))
          ""
        rescue SlashCommand::InvalidToken
          response.status = 403
          ""
        rescue SlashCommand::MissingParams
          response.status = 422
          ""
        end
      end

      r.on "actions" do
        r.post 'list_unestimated' do
          cmd = ActionCommand.new(r.params, ENV['ESTIMATES_TOKEN'])
          ListUnestimatedJob.perform_async(cmd)
          ""
        rescue SlashCommand::InvalidToken
          response.status = 403
          ""
        rescue SlashCommand::MissingParams
          response.status = 422
          ""
        end
      end
    end
  end
end
