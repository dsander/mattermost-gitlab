# frozen_string_literal: true

RSpec.describe SlashCommand do
  let(:command) { SlashCommand.new(params, nil) }

  it "sends a response to mattermost" do
    stub_request(:post, "https://mattermost.local/hooks/commands/rri1ri1s53gu5g37kckk46qsfh")
      .with(
        body: "{\"text\":\"Hello\\nworld\",\"response_type\":\"ephemeral\",\"icon_url\":\"http://icon.com\",\"username\":\"test\"}",
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 200, body: "", headers: {})
    command.respond(lines: %w[Hello world], icon: 'http://icon.com', username: "test")
  end
end
