# encoding: UTF-8

require_folder(site.folder_objet+'user/signup/lib')
class Signup
class << self

  include MethodesMainObjet

  # Quand un utilisateur passe par ici alors qu'il est identifié,
  # on le renvoie vers sa page de profil.
  def redirect_to_profil
    flash("Vous êtes déjà inscrit#{user.f_e} à l'atelier Icare, #{user.pseudo} !")
    site.redirect_to('user/profil')
  end

end #/<< self
end #/Signup
