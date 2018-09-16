# encoding: UTF-8

def le_fichier path, options = nil
  TestFile.new(path, options)
end

class User
  include RSpec::Matchers
  # include Capybara::DSL
  # include RSpecHtmlMatchers

  # Produit un succès si on trouve le document +doc_name+
  # dans le dossier de téléchargement.
  # Produit un échec dans le cas contraire
  def telecharge_le_fichier doc_name, options = nil
    if (folder_telechargement + doc_name).exist?
      success "Le fichier “#{doc_name}” a bien été downloadé."
    else
      raise "Le fichier “#{doc_name}” n'a pas été downloadé."+
        ' (noter que le navigateur doit être réglé pour downloadé directement les fichiers dans le dossier des téléchargements)'
    end
  end

  # Note : c'est une action, pas un test. Il faut ensuite vérifier
  # que le fichier dézippé existe bel et bien.
  #
  # Si options[:final_name] existe, c'est un test
  def dezippe_le_fichier doc_path, options = nil
    options ||= Hash.new
    final_name = options[:final_name]
    doc_path.instance_of?(SuperFile) || doc_path = SuperFile.new(doc_path)
    doc_path.exist? || (raise "Le fichier “#{doc_path}” est introuvable. Impossible de le dézipper.")
    res = `unzip -o "#{doc_path}"`
    if final_name
      if res.include?("inflating: #{final_name}")
        success "Le fichier “#{doc_path}” a bien été dézippé."
      else
        raise "Le fichier “#{doc_path}” n'a pas pu être dézippé."
      end
    end
  end

  def folder_telechargement
    @folder_telechargement ||= SuperFile.new([Dir.home, 'Downloads'])
  end

end

class TestFile
  attr_reader :path
  attr_reader :options
  def initialize path, options = nil
    @path     = path
    @options  = options || Hash.new
  end

  # ---------------------------------------------------------------------
  # Méthode de test
  # ---------------------------------------------------------------------
  def existe opts = nil
    opts.nil? || @options = opts
    if File.exist? path
      success options[:success] || "Le fichier `#{path}` existe."
    else
      raise options[:failure] || "Le fichier `#{path}` n'existe pas."
    end
  end
  def nexistepas opts = nil
    opts.nil? || @options = opts
    if File.exist? path
      raise options[:failure] || "Le fichier `#{path}` ne devrait pas exister"
    else
      success options[:success] || "Le fichier `#{path}` n'existe pas."
    end
  end

end #/TestFile
