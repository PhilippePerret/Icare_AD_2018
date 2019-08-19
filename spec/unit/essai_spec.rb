
describe site do
  it 'répond à output' do
    expect(site).to respond_to :output
  end
  it 'output retourne le code de la page' do
    code = site.output.to_s
    expect(code).to be_instance_of String
  end
end
