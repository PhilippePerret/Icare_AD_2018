# encoding: UTF-8
=begin

Module définissant les paths utiles

=end
class LaTexBook

  # {SuperFile} de la table des matières
  def file_tdm
    @file_tdm ||= begin
      p = nil
      ["tdm", "TDM", "_tdm_", "_TDM_"].each do |aff|
        p = SuperFile::new([sources_folder, "#{aff}.yaml"])
        break if p.exist?
      end
      p
    end
  end

  # {SuperFile} Fichier qui peut contenir un code à insérer
  # avant tous les fichiers markdown (par exemple la définition des
  # liens)
  def pre_code_markdown_file
    @pre_code_markdown_file ||= SuperFile::new([sources_folder,'pre_code_markdown.md'])
  end

  # {SuperFile} Dossier contenant les fichiers latex assets propres
  # au livre
  def assets_folder
    @assets_folder ||= SuperFile::new([folder_path, 'assets'])
  end

  # {SuperFile} Fichier contenant les données du livre
  def file_book_data
    @file_book_data ||= SuperFile::new([folder_path, "book_data.rb"])
  end

  # Suffixe à ajouter au nom du PDF final
  def suffixe_version
    @suffixe_version ||= begin
      if    version_femme === true
        "_vF"
      elsif version_femme === false
        "_vH"
      else# version_femme === nil
        ""
      end
    end
  end

  # {SuperFile} Le path du fichier final
  def pdf_file
    @pdf_file ||= SuperFile::new([main_folder, "#{pdf_name||'latexbook'}#{suffixe_version}.pdf"])
  end
  def pdf_file= value; @pdf_file = value end

  # Dossier contenant les images
  def images_folder
    @images_folder ||= SuperFile::new([sources_folder, 'img'])
  end

  # Dossier principal (qui contient le dossier des sources)
  # C'est dans ce dossier que sera mis par défaut le manuel
  # PDF final
  def main_folder
    @main_folder ||= File.dirname(self.folder_path)
  end

end #/LaTexBook
