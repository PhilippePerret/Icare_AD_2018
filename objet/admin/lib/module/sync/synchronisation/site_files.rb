# encoding: UTF-8
class Sync

  def synchronize_site_files
    @report << "* Synchronisation de tous les fichiers du site"
    (site.folder_deeper + 'module/synchronisation/synchronisation.rb').require
    @report << "= Synchronisation de tous les fichiers opérée avec succès"
  rescue Exception => e
    @errors << "Impossible de synchroniser tous les fichiers : #{e.message}"
    @errors << e.backtrace.join("\n")
  end

end #/Sync
