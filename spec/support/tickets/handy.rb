# encoding: UTF-8

def ticket_should_exist hdata
  w = TTicket.new(hdata)
  expect(w).to is_ticket
  return w.wdata
end


class DB
class << self
  def getTicket hdata
    DB.getOne('icare_hot.tickets', hdata)
  end
end #/<< self
end

RSpec::Matchers.define :is_ticket do
  match do |actual|
    @w = actual
    actual.is_a?(TTicket) && actual.existe
  end
  description do
    "Le ticket #{@w.ref} existe."
  end
  failure_message do
    "Le ticket #{@w.ref} devrait exister"
  end
  failure_message_when_negated do
    "Le ticket #{@w.ref} ne devrait pas exister"
  end
end
