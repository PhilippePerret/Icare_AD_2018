

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
