# frozen_string_literal: true

RSpec.describe '/api/actions/list_unestimated' do
  it 'works with the correct parameters' do
    expect(ListUnestimatedJob).to receive(:perform_async)
    post '/api/actions/list_unestimated', unestimated_params, {}
    expect(response.status).to eq(200)
  end

  it 'it fails with the wrong token' do
    tkn = ENV.delete('ESTIMATES_TOKEN')
    ENV['ESTIMATES_TOKEN'] = 'something'
    post '/api/actions/list_unestimated', unestimated_params, {}
    ENV['ESTIMATES_TOKEN'] = tkn
    expect(response.status).to eq(403)
  end

  it 'errors when parameters are missing' do
    post '/api/actions/list_unestimated', nil, {}
    expect(response.status).to eq(422)
  end
end
