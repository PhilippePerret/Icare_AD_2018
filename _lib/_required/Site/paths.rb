# encoding: UTF-8
class SiteHtml

  # ---------------------------------------------------------------------
  #   URLs
  # ---------------------------------------------------------------------

  # Défini par le fichier de configuration
  # def distant_host  ; @distant_host end
  # def local_host    ; @local_host   end

  def local_url
    @local_url ||= "http://#{self.local_host}"
  end
  alias :url_locale :local_url
  def distant_url
    @distant_url ||= "http://#{self.distant_host}"
  end
  alias :url_distante :distant_url

  # L'URL de la boite à outils
  def url_boa
    @url_boa ||= 'http://www.laboiteaoutilsdelauteur.fr'
  end
  alias :boa_url :url_boa


  # URL en fonction de où on consulte le site
  def url
    ONLINE ? distant_url : local_url
  end

  # Destruction de la page d'accueil pour forcer son
  # actualisation (suite à une nouvelle actualité du site)
  def destroy_home
    file_home_page_content.destroy if file_home_page_content.exist?
  end

  # {SuperFile} Fichier contenant le code HTML de la
  # page d'accueil, qui doit être reconstruit dès qu'une
  # actualité a été générée.
  def file_home_page_content
    @file_home_page_content ||= folder_objet+'site/home.html'
  end

  # ---------------------------------------------------------------------
  #   Méthodes utiles pour les paths
  # ---------------------------------------------------------------------

  # Construit le dossier si nécessaire.
  # Noter que ça ne sert pas seulement à site
  # @usage    site.get_and_build_folder( path/to/folder )
  def get_and_build_folder sfile
    sfile = SuperFile.new(sfile) unless sfile.instance_of?(SuperFile)
    sfile.build unless sfile.exist?
    return sfile
  end

  # ---------------------------------------------------------------------
  #   Données
  # ---------------------------------------------------------------------
  def folder_data_secret
    @folder_data_secret ||= get_and_build_folder(folder_data+'secret')
  end

  # ---------------------------------------------------------------------
  #   Images
  # ---------------------------------------------------------------------
  def folder_images
    @folder_images ||= get_and_build_folder('./_view/img')
  end
  # ---------------------------------------------------------------------
  #   Database
  # ---------------------------------------------------------------------

  def folder_db_users
    folder_db_users ||= get_and_build_folder(folder_db + 'user')
  end

  # Les données de l'application, c'est-à-dire le contenu de
  # toutes les bases de données.
  # Note : C'est ce dossier qui est copié pour faire des gels
  def folder_db
    @folder_db ||= get_and_build_folder(folder_database + 'data')
  end
  alias :folder_data_database :folder_db

  # Dossier qui contient la définition des tables
  def folder_tables_definition
    @folder_tables_definition ||= get_and_build_folder(folder_database + 'tables_definition')
  end
  def folder_database
    @folder_database ||= get_and_build_folder('./database')
  end

  # ---------------------------------------------------------------------
  #   Librairie de l'objet 'site'
  # ---------------------------------------------------------------------

  def folder_lib_objet_site
    @folder_lib_objet_site ||= folder_objet+'site/lib'
  end


  # ---------------------------------------------------------------------
  #   Vues (hors vue d'objet)
  # ---------------------------------------------------------------------

  def folder_gabarit
    @folder_gabarit ||= folder_view + 'gabarit'
  end
  def folder_error_pages
    @folder_error_pages ||= folder_view + 'error_pages'
  end
  def folder_user_view
    @folder_user_view ||= folder_objet + 'user/vues'
  end
  def folder_view
    @folder_view ||= SuperFile.new('./_view')
  end

  # ---------------------------------------------------------------------
  #   Librairie
  # ---------------------------------------------------------------------
  def folder_optional_modules
    @folder_optional_modules ||= folder_lib + 'modules_optional'
  end

  def folder_lib
    @folder_lib ||= app.lib_folder
  end

  # ---------------------------------------------------------------------
  #   Dossier de base
  # ---------------------------------------------------------------------

  def folder_data
    @folder_data ||= get_and_build_folder('./data')
  end

  def folder_objet
    @folder_objet ||= SuperFile.new('./_objet')
  end

  def folder_tmp
    @folder_tmp ||= begin
      d = SuperFile.new('./tmp')
      d.build unless d.exist?
      d
    end
  end

  # Dossier principal de l'application
  # ALIAS def app_folder
  def folder_app
    @folder_app ||= SuperFile.new('.')
  end
  alias :app_folder :folder_app

end
