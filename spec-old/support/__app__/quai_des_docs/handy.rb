# encoding: UTF-8
=begin

  Méthodes pratiques pour les tests avec le Quai des docs.

  Principalement, elles permettent de mettre le dossier ./data/qdd/pdfs de
  côté et de le remettre en fin de test.

=end

# Méthode à appeler en début de test pour mettre de côté le
# dossier ./data/qdd/pdfs et en créer un nouveau vide, si options[:empty_folder]
# est vraiment
def protect_qdd_pdfs options = nil
  options ||= Hash.new
  options.key?(:empty_folder) || options.merge!(empty_folder: true)
  folder_empty = !!options.delete(:empty_folder)
  fpath = site.folder_data + 'qdd/pdfs'
  fdest = site.folder_data + 'qdd/pdfs_backup'
  fdest.exist? || begin
    if folder_empty
      FileUtils.move fpath.to_s, fdest.to_s
      `mkdir -p "#{fpath}"`
    else
      FileUtils.cp_r fpath.to_s, fdest.to_s
    end
  end
end

def unprotect_qdd_pdfs
  fpath = site.folder_data + 'qdd/pdfs'
  fback = site.folder_data + 'qdd/pdfs_backup'
  fback.exist? || (raise 'Le dossier backup du Quai des docs n’existe pas, impossible de récupérer les données…')
  fpath.exist? && FileUtils.rm_rf(fpath.to_s)
  FileUtils.move fback.to_s, fpath.to_s
end
