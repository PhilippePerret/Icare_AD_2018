# encoding: UTF-8
class Cron
  def _nettoyage_site
    Nettoyage.clean_up_site
  end
class Nettoyage
class << self

  # = main =
  #
  # Méthode principale de nettoyage de l'atelier
  def clean_up_site
    log "<hr />"
    log "Nettoyage du site", {time: true}
    [
      :log_debug,
      :mails,
      :documents,
      :visites_as
    ].each do |key|
      begin
        self.send("clean_up_#{key}".to_sym)
      rescue Exception => e
        log "# Erreur au cours du nettoyage de #{key} : #{e.message}"
        log e.backtrace.join("<br>")
      end
    end
  end

  def mois_precedent
    @mois_precedent ||= Time.now.to_i - 31.days
  end

  # ---------------------------------------------------------------------
  #   Méthodes de nettoyage
  # ---------------------------------------------------------------------

  def clean_up_log_debug
    fp = SuperFile.new('./tmp/debug/debug.log')
    fp.exist? || return
    fp.remove
    log "  - Destruction du fichier debug.log"
  end

  # Nettoyage du dossier des mails (utile seulement en OFFLINE ?)
  def clean_up_mails
    fp = SuperFile.new('./tmp/mails')
    fp.exist? || return
    fp.remove
    log "  - Destruction des mails marshal"
  end

  # Nettoyage du dossier des downloads
  # Tous les dossiers plus vieux qu'un mois sont détruits
  def clean_up_documents
    folder_docs = SuperFile.new('./tmp/download')
    folder_docs.exist? || return
    nombre_dossiers_detruits = 0
    Dir["./tmp/download/*"].each do |fpath|
      File.stat(fpath).ctime.to_i < mois_precedent || next
      # Destruction du dossier
      nombre_dossiers_detruits += 1
      FileUtils.rm_rf fpath
    end
    log "  - Destruction de dossiers documents (#{nombre_dossiers_detruits})"
  end

  # Nettoyage des fichiers qui permettent de se logguer comme un
  # visiteur (./tmp/_adm)
  def clean_up_visites_as
    fold = File.join('.','tmp','_adm')
    File.exist?(fold) || return
    nombre_fichiers_detruits = 0
    Dir["#{fold}/*"].each do |fp|
      File.stat(fp).ctime.to_i < mois_precedent || next
      File.unlink fp
      nombre_fichiers_detruits += 1
    end
    log "  - Destruction des fichiers de visit_as (#{nombre_fichiers_detruits}, dans ./tmp/_adm)"
  end

end #/<< self
end #/Nettoyage
end #/Cron
