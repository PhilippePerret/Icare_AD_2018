# encoding: UTF-8
raise_unless_admin
Admin.require_module 'taches'


# ON test toujours la synchro des deux tables locales et distantes
# pour qu'elles soient synchronisées.
Admin::Taches.test_synchro


def tache_id
  @tache_id ||= param(:tid).to_i_inn
end

case param(:op)
when 'stop_tache'
  if tache_id != nil
    Admin::Taches::Tache.new(tache_id).stop
  else
    error 'Aucune tache n’est spécifiée.'
  end
when 'create_tache'
  Admin::Taches.create
end
