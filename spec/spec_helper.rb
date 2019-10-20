# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

ENV['GITLAB_HOST'] = 'https://gitlab.example.com'
ENV['GITLAB_TOKEN'] = 'token'

require_relative '../boot'

require 'webmock/rspec'
require 'rack/test'

Logging.logger = Logger.new("/dev/null")

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    Server
  end

  def response
    last_response
  end

  def json_response
    @json_response ||= JSON.parse(response.body)
  end

  def params
    { 'channel_id' => '123',
      'channel_name' => 'jgwefzmootgq8d4ak6cxtri6ia__jgwefzmootgq8d4ak6cxtri6ia',
      'command' => '/test',
      'response_url' => 'https://mattermost.local/hooks/commands/rri1ri1s53gu5g37kckk46qsfh',
      'team_domain' => 'flavoursys',
      'team_id' => 'gw7fazgpzfdb7buzb7j4jbm69c',
      'text' => 'https://gitlab.local/dashboard/issues?scope=all&utf8=%E2%9C%93&state=opened&assignee_username=dominik.sander&milestone_title=Release%206.0&label_name[]=Release',
      'token' => 'token',
      'trigger_id' => '123abc',
      'user_id' => 'jgwefzmoocxtri6ia',
      'user_name' => 'dsander' }
  end

  def unestimated_params
    { "user_id" => "jgwefzak6cxtri6ia",
      "channel_id" => "123",
      "team_id" => "",
      "post_id" => "wmwfe9yn5gykamhrc",
      "trigger_id" => "cjEzeGVrMWQ1N3Iamd3ZWZ6bW9vdGdxOGQ0YWs2Y3h0cmk2aWE6MTQUNIcTBnbG5XZWV1cnpyZkZXVVg4bzhOUmxwQ216VjIrQ1dJZkE=",
      "type" => "",
      "data_source" => "",
      "context" =>
      { "args" =>
        { "assignee_username" => "dominik.sander",
          "labels" => "Release",
          "milestone" => "Release 6.0",
          "scope" => "all",
          "state" => "opened" },
        'response_url' => 'https://mattermost.local/hooks/commands/rri1ri1s53gu5g37kckk46qsfh',
        "token" => "9o6d8ijdqj8q7piu6dx3jig34a" } }
  end

  # config.profile_examples = 10

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.default_formatter = "doc" if config.files_to_run.one?
end
