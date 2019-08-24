# encoding: UTF-8

def watcher_should_exist hdata
  w = TWatcher.new(hdata)
  expect(w).to is_watcher
  return w.wdata
end


class DB
class << self
  def getWatcher hdata
    DB.getOne('icare_hot.watchers', hdata)
  end
end #/<< self
end

RSpec::Matchers.define :is_watcher do
  match do |actual|
    @w = actual
    actual.is_a?(TWatcher) && actual.existe
  end
  description do
    "Le watcher #{@w} existe."
  end
  failure_message do
    "Le watcher #{@w.ref} devrait exister"
  end
  failure_message_when_negated do
    "Le watcher #{@w.ref} ne devrait pas exister"
  end
end


# Retourne le dernier watcher
# De l'user +user_id+ si fourni (peut être être l'user ou son ID)
def get_last_watcher user_id = nil
  dw = {order: 'created_at DESC', limit: 1}
  user_id.nil? || begin
    user_id.instance_of?(Integer) || user_id = user_id.id
    dw.merge!(user_id: user_id)
  end
  dbtable_watchers.select(dw).first
end
