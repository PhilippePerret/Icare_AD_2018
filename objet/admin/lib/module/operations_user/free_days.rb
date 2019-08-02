# encoding: UTF-8
class Admin
class Users
class << self

  # Ajout de jours à un icarien
  #
  # Le nombre de jours est contenu dans param(:opuser)[:short_value]
  # On peut également indiquer une raison dans :long_value
  def exec_free_days

    if icarien.id == 0
      debug 'L’ID de l’icarien ne devrait pas être nil. Il faut le choisir dans le menu.'
      @icarien_id = param_opuser[:user_id].to_i
      @icarien    = User.new(@icarien_id)
    end

    icarien.icmodule || begin
      debug "Pas de module courant… Ça n'est peut-être pas le bon icarien"
      @icarien_id = param_opuser[:user_id].to_i
      debug "Je prends l'icarien ##{@icarien_id}"
      @icarien    = User.new(@icarien_id)
      debug "Icarien : #{icarien.pseudo} (#{@icarien.pseudo}), ##{icarien.id} (##{@icarien.id})"
    end

    icarien.icmodule || begin
      error "L'icarien#{icarien.f_ne} #{icarien.pseudo} (#{icarien.id}) n’a pas de module courant…"
      return false
    end

    old_paiement = icarien.icmodule.next_paiement
    new_paiement = old_paiement + nombre_jours_gratuits.days

    @old_dateh_paiement  = old_paiement.as_human_date(true, false, ' ')
    @new_dateh_paiement  = new_paiement.as_human_date(true, false, ' ')

    # On enregistre la nouvelle date de paiement
    icarien.icmodule.set(next_paiement: new_paiement)

    icarien.send_mail(
      subject:        'Ajout de jours gratuits',
      message:        message_jours_gratuits,
      formated:       true,
      force_offline:  false
    )

    flash "#{nombre_jours_gratuits} jours gratuis accordés à #{icarien.pseudo}. Un mail lui a été envoyé"+
      "<br>Ancienne date de paiement : #{@old_dateh_paiement}"+
      "<br>Nouvelle date de paiement : #{@new_dateh_paiement}"
  end

  def nombre_jours_gratuits
    @nombre_jours ||= short_value.to_i
  end
  def raison_jours_gratuits
    @raison_jours_gratuits ||= long_value || 'Aucune raison invoquée'.in_p
  end

  def message_jours_gratuits
    <<-HTML
<p>Bonjour #{icarien.pseudo},</p>
<p>J'ai le plaisir de vous annoncer que Phil vient de vous accorder #{nombre_jours_gratuits} jours gratuits.</p>
<p>
  Date précédente du paiement : #{@old_dateh_paiement}<br>
  Votre nouvelle date de paiement : #{@new_dateh_paiement}
</p>
<p>La raison de ce geste est :</p>
#{raison_jours_gratuits}
    HTML
  end

end #/<< self
end #/Users
end #/Admin
