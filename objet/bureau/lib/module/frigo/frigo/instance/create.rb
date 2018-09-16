# encoding: UTF-8
class Frigo

  # Création d'un frigo
  def create
    dbtable_frigos.insert(data_creation)
  end
  def data_creation
    now = Time.now.to_i
    {
      id:             frigo.owner_id,
      last_messages:  '',
      updated_at:     now,
      created_at:     now
    }
  end

end #/Frigo
