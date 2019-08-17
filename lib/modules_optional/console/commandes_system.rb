# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Lit le fichier debug est écrit son contenu à l'écran
  def read_debug
    if debug_sfile.exist?
      sub_log debug_sfile.read.split("\n").collect{|p| p.in_div}.join("")
    else
      sub_log "Aucun fichier log à lire."
    end
    "OK"
  end

  # Détruit le fichier debug.log
  def destroy_debug
    debug_sfile.remove if debug_sfile.exist?
    sub_log "Fichier débug détruit avec succès." unless debug_sfile.exist?
    "OK"
  end

  # Lance le script de synchro
  # Note : Seulement en offline
  def check_synchro
    if ONLINE
      error "Le script de check de synchro local&lt;-&gt;distant ne peut s'utiliser qu'en OFFLINE."
      "SEULEMENT OFFLINE"
    elsif synchro_sfile.exist?
      top_require synchro_sfile
    else
      "Le fichier `#{synchro_sfile}` est introuvable. Impossible de lancer la synchro."
    end
  end


  private

    def debug_sfile
      @debug_sfile ||= SuperFile::new("./tmp/debug/debug.log")
    end

    def synchro_sfile
      @synchro_sfile ||= (site.folder_deeper + 'module/synchronisation/synchronisation.rb')
    end

end #/Console
end #/Admin
end #/SiteHtml
