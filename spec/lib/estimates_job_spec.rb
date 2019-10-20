# frozen_string_literal: true

RSpec.describe EstimatesJob do
  let(:job) { EstimatesJob.new }

  it 'sends the report' do
    gitlab_mock = instance_double("GitLab", auto_paginate: [OpenStruct.new(time_stats: OpenStruct.new(time_estimate: 3600))])
    expect(Gitlab).to receive(:issues).with(nil, assignee_username: "dominik.sander", labels: "Release",
                                                 milestone: "Release 6.0", scope: "all", state: "opened").and_return(gitlab_mock)

    expect(job).to receive(:respond).with(attachments: [
                                            { actions: [],
                                              fields: [{ short: true, title: "Assignee username", value: "dominik.sander" },
                                                       { short: true, title: "Milestone", value: "Release 6.0" },
                                                       { short: true, title: "Labels", value: "Release" },
                                                       { short: true, title: "Scope", value: "all" },
                                                       { short: true, title: "State", value: "opened" }],
                                              text: "#### 1h",
                                              title: "Time estimation summary for 1 issues",
                                              title_link: params['text'] }
                                          ],
                                          lines: [],
                                          response_type: "in_channel")

    job.perform(SlashCommand.new(params, nil), "http:/hostname.local")
  end

  it 'includes an action if at least one issues does not have an estimation' do
    expect(job).to receive(:load_issues).and_return([3600, [1, 2], ["https://gitlab.com/issues/1"]])

    expect(job).to receive(:respond).with(attachments: [
                                            {
                                              actions: [
                                                { integration: { context: { args: { assignee_username: "dominik.sander",
                                                                                    labels: "Release",
                                                                                    milestone: "Release 6.0",
                                                                                    scope: "all",
                                                                                    state: "opened" },
                                                                            response_url: "https://mattermost.local/hooks/commands/rri1ri1s53gu5g37kckk46qsfh",
                                                                            token: nil },
                                                                 url: "http:/hostname.local/api/actions/list_unestimated" },
                                                  name: "Show 1 issues without estimates" }
                                              ],
                                              fields: [{ short: true, title: "Assignee username", value: "dominik.sander" },
                                                       { short: true, title: "Milestone", value: "Release 6.0" },
                                                       { short: true, title: "Labels", value: "Release" },
                                                       { short: true, title: "Scope", value: "all" },
                                                       { short: true, title: "State", value: "opened" }],
                                              text: "#### 1h",
                                              title: "Time estimation summary for 2 issues",
                                              title_link: params['text']
                                            }
                                          ],
                                          lines: [],
                                          response_type: "in_channel")

    job.perform(SlashCommand.new(params, nil), "http:/hostname.local")
  end

  it 'warns if no filters are given' do
    expect(job).to receive(:respond).with(lines: array_including(/Invalid URL/))
    job.perform(SlashCommand.new(params.merge('text' => 'notaurl'), nil), "http:/hostname.local")
  end

  it 'sends exceptions back to the requester' do
    expect(Gitlab).to receive(:issues).and_raise(ArgumentError, "woups")

    expect(job).to receive(:respond).with(lines: array_including("woups"))
    job.perform(SlashCommand.new(params, nil), "http:/hostname.local")
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
