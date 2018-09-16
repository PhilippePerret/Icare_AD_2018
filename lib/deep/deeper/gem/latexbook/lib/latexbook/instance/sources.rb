# encoding: UTF-8
=begin
class LaTexBook::Source
Module pour la gestion des fichiers
=end
class LaTexBook
class Source

  # ---------------------------------------------------------------------
  #   Class
  # ---------------------------------------------------------------------
  class << self

    def traite_all
      log "* Traitement de toutes les sources"
      all.each do |source_path|
        s = new(source_path)
        s.traite
      end
      log "= Traitement des sources OK"
    end

    # Retourne tous les fichiers dans l'ordre
    def all
      @all ||= begin
        # Si un fichier table des matières existe, on le
        # prend, sinon, on relève les fichiers dans l'ordre
        if book.file_tdm.exists?
          arr = Array::new
          YAML::load_file(book.file_tdm.to_s).each do |dossier, liste|
            liste.each do |source|
              arr << File.join(book.sources_folder.to_s, dossier.to_s, "#{source}.md")
            end
          end
          arr
        else
          Dir["#{book.sources_folder}/**/*.md"]
        end
      end
    end

    def pre_code_markdown
      @pre_code_markdown ||= begin
        if book.pre_code_markdown_file.exist?
          book.pre_code_markdown_file.read + "\n\n"
        else
          ""
        end
      end
    end

    # Raccourcis
    def book; @book ||= LaTexBook::current end
    def log mess; book.log( mess ) end

  end #/<<self LaTexBook::Source

  # ---------------------------------------------------------------------
  #   Instance LaTexBook::Source
  # ---------------------------------------------------------------------
  attr_reader :path
  def initialize path
    @path = path
  end

  def book ; @book ||= LaTexBook::current end

  # = main =
  #
  # Méthode principale qui traite la source
  #
  def traite
    log "  * Traitement #{path}"
    build_folder_if_needed
    to_source_latex
    as_inclusion
    log "    = Traitement OK"
  end

  # Méthode qui construit le dossier qui va contenir le
  # fichier latex si nécessaire
  def build_folder_if_needed
    return if latex_file.folder.exist?
    log "    -> Construction du dossier du fichier latex"
    `mkdir -p "#{latex_file.folder.to_s}"`
  end
  # Méthode qui prend le fichier source Markdown et
  # en fait un fichier source LaTex
  #
  def to_source_latex
    log "    -> Markdown vers LaTex"
    markdown_file.kramdown(output_format: :latex, in_file: latex_file, pre_code: self.class::pre_code_markdown)
    # Quelques corrections après avoir kramdowné le fichier
    latex_file.corrections_latex
  end

  # Méthode qui ajoute la ligne d'inclusion dans le fichier
  # all_sources
  #
  def as_inclusion
    log "    -> Inclusion dans all_sources.tex"
    LaTexBook::all_sources_tex_file.append("\\input{sources/#{relative_affixe}}\n")
  end

  # Path du fichier LaTex qui contient le code LaTex (donc
  # le fichier de destination)
  def latex_file
    @latex_file ||= LaTexBook::sources_folder + "#{relative_affixe}.tex"
  end
  def markdown_file
    @markdown_file ||= SuperFile::new(path)
  end

  # Chemin relatif (affixe)
  def relative_affixe
    @relative_affixe ||= relative_path.to_s[0..-4] # - ".md"
  end
  # Chemin relatif
  def relative_path
    @relative_path ||= path.to_s.sub(/^#{book.sources_folder.to_s}\//,'')
  end

  # Raccourci pour les messages
  def log mess; LaTexBook::current.log( mess ) end

end #/Source
end #/LaTexBook
