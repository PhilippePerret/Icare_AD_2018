# encoding: UTF-8
raise_unless_admin
=begin

  Module inauguré pour procéder à des opérations administrateur qui
  ne peuvent pas être accomplies autrement. Par exemple, pour télécharger
  les documents s'inscription d'un candidat (document qui n'est plus
  enregistré comme document normal)

  USAGE
  =====

      opadmin     Doit contenir le nom de l'opération

  On revient toujours à la page précédente
=end
begin

  case param(:opadmin)


  when 'download_signup'
    #
    # === Chargement des documents de présentation ===
    # 
    fpath = site.folder_tmp + "signup/#{param(:sid)}/documents"
    if fpath.exist?
      fpath.download
    else
      raise "Le dossier de candidature #{fpath} est introuvable…"
    end


  else
    raise "L'opération administrateur `#{param(:opadmin)}` n'est pas définie."
  end

rescue Exception => e
  debug e
  error e.message
ensure
  redirect_to :last_page
end
