# encoding: UTF-8
raise_unless_admin
# require 'yaml'
alias :top_require :require
class SiteHtml
class Admin
class Console


  def affiche_aide_for sujet
    top_require 'yaml'

    # Cas spécial quand +sujet+ = "sujets", on veut obtenir la
    # liste de tous les sujets qui existent. On les trouve dans
    # les fichiers YAML de l'application et des RestSites en
    # générale
    if sujet == "sujets"
      affiche_liste_sujets_aide
    else
      hdata = YAML::load_file( _("help.yml") )
      unless hdata.has_key?(sujet.to_s)
        hdata = YAML::load_file( (console.folder_app + "help_app.yml").to_s )
      end
      if hdata.has_key?(sujet.to_s)
        @iclosedpart = 1
        sub_log ( miste_en_forme_liste_aides hdata[sujet.to_s], not_displayed=false )
        ""
      else
        error "Le sujet `#{sujet}` est inconnu. Taper `aide sujets` ou `help sujets` pour obtenir la liste des sujets possibles."
        "ERROR"
      end
    end

  end

  # Affiche la liste des sujets
  # (répond à la commande `aide sujets`)
  def affiche_liste_sujets_aide
    c = String::new
    c << "(il suffit de taper `<em>aide &lt;sujet&gt;</em>` pour obtenir l'aide)".in_p
    c << "Sujets des RestSites en général".in_h3
    hdata = YAML::load_file( _("help.yml") )
    c << hdata.keys.join("<br />").in_div
    c << "Sujets de l'application en particulier".in_h3
    hdata = YAML::load_file( (console.folder_app+"help_app.yml").to_s )
    c << hdata.keys.join("<br />").in_div
    sub_log c
    ""
  end


  #
  # AIDE
  #
  def help
    require 'yaml'
    # Le code total construit
    c = String::new
    # Pour incrémenter les parties fermées
    @iclosedpart = 1
    # On traite l'aide commune à tous les RestSite
    c << "Aide propre aux sites RestSite".in_h3(class:'underline')
    c << mise_en_forme_aide( _("help.yml") )
    # On traite l'aide propre à l'application courante
    c << "Aide propre à l'application".in_h3(class:'underline')
    c << mise_en_forme_aide( _("help_app.yml") )

    return c
  end

  # Retourne le code HTML de la mise en forme du
  # fichier d'aide `path` (qui en fait se résume au nom du fichier
  # à la racine de ce même dossier)
  # +iclosepart+ Indice de la partie courante, pour le numérotage des
  # section qui produiront des liens pour les ouvrir/fermer.
  def mise_en_forme_aide path
    c = String::new
    YAML::load_file( path ).each do |sujet, liste_sujet|
      c << ( miste_en_forme_liste_aides liste_sujet )
    end
    return c
  end

  def miste_en_forme_liste_aides liste, not_displayed = true
    iclosepart_init = @iclosedpart.freeze
    c = String::new
    liste.each do |haide|
      case haide['type']
      when 'TITLE'
        c << "</dl>" if @iclosedpart > 1
        @iclosedpart += 1
        dl_id = "description_list-#{@iclosedpart}"
        c << "<h4 onclick=\"$('dl##{dl_id}').toggle()\">#{haide['description']}</h4>"
        c << "<dl id=\"#{dl_id}\" class=\"small\" style=\"display:#{not_displayed ? 'none' : 'block'}\">"
      when 'GOTO'
      when 'HELP'
      else
        c << haide['command'].in_dt
        c << haide['description'].gsub(/\n/,'<br>').in_dd
        c << haide['note'].gsub(/\n/,'<br>').in_dd(class:'note')      unless haide['note'].nil?
        c << haide['implement'].in_dd(class:'imp')  unless haide['implement'].nil?
      end
    end
    c << "</dl>" if @iclosedpart > iclosepart_init
    return c
  end

end #/Console
end #/Admin
end #/SiteHtml
