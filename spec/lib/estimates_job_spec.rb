RSpec.describe EstimatesJob do
  let(:job) { EstimatesJob.new }

  it 'sends the report' do
    gitlab_mock = instance_double("GitLab", auto_paginate: [OpenStruct.new(time_stats: OpenStruct.new(time_estimate: 3600))])
    expect(Gitlab).to receive(:issues).with(nil, assignee_username: "dominik.sander", labels: "Release", milestone: "Release 6.0", scope: "all", state: "opened").and_return(gitlab_mock)

    expect(job).to receive(:respond).with(lines: array_including("1 issues: **1h**"), response_type: 'in_channel')
    expect(job).to receive(:respond).with(lines: array_including("Issues missing estimations:"))
    job.perform(SlashCommand.new(params, nil))
  end

  it 'warns if no filters are given' do
    expect(job).to receive(:respond).with(lines: array_including(/Invalid URL/))
    job.perform(SlashCommand.new(params.merge('text' => 'notaurl'), nil))
  end

  it 'sends exceptions back to the requester' do
    gitlab_mock = instance_double("GitLab", auto_paginate: [OpenStruct.new(time_stats: OpenStruct.new(time_estimate: 3600))])
    expect(Gitlab).to receive(:issues).and_raise(ArgumentError, "woups")

    expect(job).to receive(:respond).with(lines: array_including("woups"), response_type: 'in_channel')
    job.perform(SlashCommand.new(params, nil))
  end

  it 'respond calls the command' do
    cmd = SlashCommand.new(params, nil)
    expect(cmd).to receive(:respond)
    job.instance_variable_set(:@command, cmd)
    job.respond(lines: ["test"])
  end
end
