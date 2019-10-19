RSpec.describe EstimatesJob do
  let(:job) { EstimatesJob.new }

  it 'sends the report' do
    gitlab_mock = instance_double("GitLab", auto_paginate: [OpenStruct.new(time_stats: OpenStruct.new(time_estimate: 3600))])
    expect(Gitlab).to receive(:issues).with(nil, assignee_username: "dominik.sander", labels: "Release",
                                                 milestone: "Release 6.0", scope: "all", state: "opened").and_return(gitlab_mock)

    expect(job).to receive(:respond).with(lines: array_including("1 issues: **1h**"), response_type: 'in_channel')
    expect(job).to receive(:respond).with(lines: array_including("Issues missing estimations:"))
    job.perform(SlashCommand.new(params, nil))
  end

  it 'warns if no filters are given' do
    expect(job).to receive(:respond).with(lines: array_including(/Invalid URL/))
    job.perform(SlashCommand.new(params.merge('text' => 'notaurl'), nil))
  end

  it 'sends exceptions back to the requester' do
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

  context '#seconds_to_human' do
    [[3600, '1h'], [3600 * 9, '1d 1h'], [3600 * 41, '1w 1h'], [3600 * 53, '1w 1d 5h']].each do |seconds, result|
      it "works for #{seconds} seconds" do
        expect(job.seconds_to_human(seconds)).to eq(result)
      end
    end
  end

  context '#url_to_api_params' do
    it 'works' do
      expect(job.url_to_api_params('?scope=all&utf8=%E2%9C%93&state=opened&assignee_username=dominik.sander&milestone_title=Release%206.0&label_name[]=Release')).to \
        eq(assignee_username: "dominik.sander", labels: "Release", milestone: "Release 6.0", scope: "all", state: "opened")
    end

    it 'with multiple labels' do
      expect(job.url_to_api_params('?label_name[]=Release&label_name[]=Test')).to \
        eq(labels: 'Release,Test')
    end

    it 'with multiple labels' do
      expect(job.url_to_api_params('?scope=all')).to \
        eq(scope: 'all')
    end
  end
end
