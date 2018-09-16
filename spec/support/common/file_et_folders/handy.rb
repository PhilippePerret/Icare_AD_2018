# encoding: UTF-8

# Dossier de téléchargement, sur le bureau
def downloads_folder
  @downloads_folder ||= SuperFile.new([Dir.home, 'Downloads'])
end

class String

  # Retourne le path du document portant le nom self, dans le dossier
  # asset/documents des tests.
  #
  # CRÉE LE DOCUMENT S'IL N'EXISTE PAS, en respectant l'extension.
  #
  # Pour utiliser la tournure <nom document>.in_folder_documents
  # Par exemple 'Mon document'.in_folder_documents
  #
  def in_folder_document
    fname = self
    fpath = File.expand_path File.join('.','spec','asset', 'document', fname)
    # On crée le document si nécessaire
    File.exist?(fpath) || begin
      fext = File.extname(fname)
      fsrc = Dir["./spec/asset/document/*#{fext}"].first
      fsrc ||= Dir["./spec/asset/document/*.*"].first
      FileUtils.cp fsrc, fpath
    end
    return fpath
  end
end
