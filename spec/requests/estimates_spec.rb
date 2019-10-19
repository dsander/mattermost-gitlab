RSpec.describe '/api/slash/estimates' do
  it 'works with the correct parameters' do
    expect(EstimatesJob).to receive(:perform_async)
    post '/api/slash/estimates', params, {}
    expect(response.status).to eq(200)
  end

  it 'it fails with the wrong token' do
    tkn = ENV.delete('ESTIMATES_TOKEN')
    ENV['ESTIMATES_TOKEN'] = 'something'
    post '/api/slash/estimates', params, {}
    ENV['ESTIMATES_TOKEN'] = tkn
    expect(response.status).to eq(403)
  end

  it 'errors when parameters are missing' do
    post '/api/slash/estimates', nil, {}
    expect(response.status).to eq(422)
  end
end
