# encoding: UTF-8
=begin

  Pour interrompre un module d'apprentissage.

=end
class Admin
class Users
class << self

  # Enregistrement du témoignage
  def exec_temoignage
    if short_value.to_s != ''
      # <= un ID a été fourni
      # => C'est l'ID du témoignage qui est modifié
      error "Pour le moment, je ne peux pas procéder à la modification d'un témoignage. Utiliser plutôt les bases (cold::temoignages)"
    else
      tdata = {
        user_id:      icarien.id,
        user_pseudo:  icarien.pseudo,
        content:      long_value.gsub(/[\n\r]/,''),
        confirmed:    1,
        created_at:   Time.now.to_i,
        updated_at:   Time.now.to_i
      }
      site.dbm_table(:cold, 'temoignages').insert(tdata)
      @suivi << "Enregistrement du témoignage de #{icarien.pseudo} (#{icarien_id})."
    end
  end

end #<< self
end #Users
end #Admin
