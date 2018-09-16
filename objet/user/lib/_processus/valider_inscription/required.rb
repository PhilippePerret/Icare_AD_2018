# encoding: UTF-8
=begin

  Toutes les méthodes requises pour la validation de l'inscription

=end
def data_modules
  @data_modules ||= begin
    if File.exist?(path_data_modules_raw)
      JSON.parse(File.read(path_data_modules_raw))
    else
      Marshal.load(path_data_modules.read)
    end
  end
end
def data_documents
  @data_documents ||= Marshal.load(path_data_documents.read)
end
def path_data_modules
  @path_data_modules ||= folder_signup + 'modules.msh'
end
# Ce path sert dans le cas où il faut modifier la liste
# des modules choisis par l'user en la forçant. Il suffit
# de faire un fichier 'modules.raw', dans son dossier
# d'inscription (dans tmp/signup) contenant la liste des
# ID de module : [<idmod1>, <idmod2>, ...]
def path_data_modules_raw
  @path_data_modules_raw ||= folder_signup + 'modules.raw'
end
def path_data_documents
  @path_data_documents ||= folder_signup + 'documents.msh'
end

# Le dossier contenant les données de l'inscription
def folder_signup
  @folder_signup ||= site.folder_tmp + "signup/#{data}"
end
