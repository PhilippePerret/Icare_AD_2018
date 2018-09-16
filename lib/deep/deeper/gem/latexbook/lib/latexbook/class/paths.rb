# encoding: UTF-8
class LaTexBook
class << self

  # {SuperFile} Fichier main.pdf
  def main_pdf_file
    @main_pdf_file ||= compilation_folder + 'main.pdf'
  end
  # {SuperFile} Fichier main.tex
  def main_tex_file
    @main_tex_file ||= compilation_folder + 'main.tex'
  end

  def main_log_file
    @main_log_file ||= compilation_folder + 'main.log'
  end

  def images_folder
    @images_folder ||= compilation_folder + 'img'
  end

  # {SuperFile} Fichier all_sources.tex
  def all_sources_tex_file
    @all_sources_tex_file ||= compilation_folder + 'all_sources.tex'
  end

  # {SuperFile} Dossier contenant les assets (qui viendront du
  # livre lui-même)
  def assets_folder
    @assets_folder ||= compilation_folder + 'assets'
  end

  # {SuperFile} Dossier qui va contenir les sources latex
  def sources_folder
    @sources_folder ||= compilation_folder + 'sources'
  end

  def compilation_folder
    @compilation_folder ||= SuperFile::new([FOLDER_LATEXBOOK,"compilation"])
  end

end #/<< self
end #/LaTexBook
