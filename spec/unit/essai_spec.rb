
describe site do
  it 'répond à output' do
    expect(site).to respond_to :output
  end
end
