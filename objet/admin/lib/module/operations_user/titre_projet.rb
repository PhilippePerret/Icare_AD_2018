# encoding: UTF-8
class Admin
class Users
class << self

  # Procédure permettant de définir le titre d'un projet d'un Icarien
  #
  # Si la short_value est définie, c'est l'ID de l'IcModule (car l'icarien
  # peut en avoir fait plusieurs et on peut définir ce titre plus tard)
  # Donc short_value contient l'ID du projet et medium_value contient
  # le titre du projet.
  def exec_titre_projet

    # Le projet visé
    imodule =
      if short_value.nil?
        icarien.icmodule
      else
        site.require_objet 'ic_module'
        IcModule.new(short_value.to_i)
      end

    # Le module doit exister
    imodule != nil || raise('L’icarien ne possède pas de module courant, il faut donner l’ID de l’IcModule.')
    imodule.exist? || raise("Impossible d'obtenir le module à titrer…")

    # Le titre du projet (noter qu'il peut être nil)
    titre_projet = medium_value.nil_if_empty

    # On peut donner le titre du projet
    imodule.set(project_name: titre_projet)

    if titre_projet.nil?
      flash "Le titre du projet ##{imodule.id} a été supprimé."
    else
      flash "Le titre du projet ##{imodule.id} a été défini à “#{titre_projet}”"
    end


  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
