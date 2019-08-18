# encoding: UTF-8
class Admin
class Users
class << self

  def exec_add_actualite
    site.require_objet 'actualite'
    mess = long_value.gsub(/\#\{(.*?)\}/){
      eval($1)
    }
    aid = SiteHtml::Actualite.create(
      user_id: icarien.id,
      message: mess
    )
    @suivi << "Nouvelle actualité ##{aid.inspect} créée avec succès pour #{icarien.pseudo}."
  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
