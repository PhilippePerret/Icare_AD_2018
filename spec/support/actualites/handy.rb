
# Procède au test de l'existence de l'actualité et retourne
# ses données si elle a été trouvée
def actualite_should_exist hdata
  upd = TUpdate.new(hdata)
  expect(upd).to is_actualite
  return upd.all_data
end

class DB
class << self
  def getUpdate hdata
    DB.getOne('icare_hot.actualites', hdata)
  end
end #/<< self
end

RSpec::Matchers.define :is_actualite do
  match do |actual|
    @w = actual
    actual.is_a?(TUpdate) && actual.existe
  end
  description do
    "L'actualité #{@w.ref} existe."
  end
  failure_message do
    "L'actualité' #{@w.ref} devrait exister"
  end
  failure_message_when_negated do
    "L'actualité #{@w.ref} ne devrait pas exister"
  end
end
