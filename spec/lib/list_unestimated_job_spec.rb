# frozen_string_literal: true

RSpec.describe ListUnestimatedJob do
  let(:job) { ListUnestimatedJob.new }

  it 'sends the report' do
    expect(job).to receive(:load_issues).and_return([nil, nil, ["http://gitlab.com/issues/1"]])
    expect(job).to receive(:respond).with(lines: ["Issues missing estimations:", "http://gitlab.com/issues/1"])

    job.perform(ActionCommand.new(unestimated_params, nil))
  end

  it 'warns if no filters are given' do
    expect(job).to receive(:respond).with(lines: array_including(/Invalid URL/))
    params = unestimated_params
    params['context']['args'] = {}
    job.perform(ActionCommand.new(params, nil))
  end

  it 'sends exceptions back to the requester' do
    expect(Gitlab).to receive(:issues).and_raise(ArgumentError, "woups")

    expect(job).to receive(:respond).with(lines: array_including("woups"))
    job.perform(ActionCommand.new(unestimated_params, nil))
  end
end
