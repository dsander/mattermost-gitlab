RSpec.describe '/' do
  it 'should return success' do
    get '/', nil, {}
    expect(response.status).to eq(200)
  end
end
