# encoding: UTF-8
=begin

  Ce module a été inauguré pour enregistrer les témoignages des
  icariens à partir de leur dernière étape.

=end
class Atelier
class Temoignage
class << self

  def save
    temoignage != nil || begin
      error 'Il faut donner votre témoignage !'
      return
    end
    temoignage.length < 65001 || begin
      error 'Désolé, mais votre témoignage est vraiment trop long (65000 caractères maximum).'
      return
    end
    temoignage.length > 20 || begin
      error 'Désolé, mais un texte de moins de 20 caractères, on ne peut pas vraiment appeler cela un témoignage… si ?'
      return
    end

    # Tout est bon, on peut l'enregistrer

    # L'auteur du témoignage
    # ATTENTION : ça n'est pas forcément l'auteur courant (par exemple lorsque
    # je modifie un témoignage avec des fautes). Donc on prend l'objet_id de
    # la route, qui est l'user du témoignage.
    uid = site.current_route.objet_id
    u   = User.new(uid)
    hmod = dbtable_icmodules.select(where:{user_id: uid}, colonnes:[:abs_module_id], order: 'started_at DESC', limit: 1).first
    hmod ||= Hash.new # normalement, n'arrive pas

    data_tem = {
      user_id:        uid,
      user_pseudo:    u.pseudo,
      abs_module_id:  hmod[:abs_module_id],
      content:        temoignage,
      confirmed:      0, # à confirmer
      created_at:     Time.now.to_i,
      updated_at:     Time.now.to_i
    }
    tem_id = dbtable_temoignages.insert(data_tem)

    # Message à Phil
    site.send_mail_to_admin(
      subject: 'Nouveau témoignage à valider',
      formated: true,
      message: <<-HTML
      <p>Phil,</p>
      <p>Un nouveau témoignage (##{tem_id}) vient d'être déposé par #{u.pseudo} (##{uid}).</p>
      <p>Il est à valider. Pour le moment, il faut le faire en affichant la table `cold > temoignages` et en exécutant le code `set(#{tem_id}, {confirmed: 1})`).</p>
      HTML
    )
    # Message de remerciement
    flash "Merci pour ce témoignage, qui devrait apparaitre très bientôt sur le site ! ;-)"
  end

  # Le témoignage transmis
  def temoignage
    @temoignage ||= begin
      tem = param(:temoignage).nil_if_empty
      tem = tem.strip_tags.to_html if tem != nil
      tem
    end
  end

end #/<< self
end #/Temoignage
end #/Atelier

begin
  case param(:operation)
  when 'save_temoignage'
    Atelier::Temoignage.save
  end

rescue Exception => e
  debug e
  send_error_to_admin(exception: e)
  error "Un problème est survenu au cours de l'opération : #{e.message}"
ensure
  redirect_to :last_page
end
