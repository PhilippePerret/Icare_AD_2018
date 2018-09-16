# encoding: UTF-8
=begin

L'objet de ce module est de permettre rapidement de transformer
un fichier Markdown (kramdown) en fichier PDF en passant par
LaTex.

Ce module est rendu nécessaire déjà pour être "indépendant" de
toute application comme Mou et aussi parce que Mou ne sait pas
traiter plein de choses à commencer par les liens par références
ou les liens tout courts.

@usage

    site/md_to_pdf?file=path/to/the/file.md

@produit

    Un fichier enregistré au même niveau, de même affixe, et
    un lien permettant de le charger.

=end

class FileMD
  attr_reader :path_md
  attr_reader :fullpath_md

  def initialize path
    @path_md = SuperFile::new(path)
    @fullpath_md = @path_md.expanded_path
  end

  # = main =
  # Transforme le fichier en fichier PDF
  #
  def to_pdf
    debug "-> to_pdf"
    debug "   * Chargement module 'kramdown' (SuperFile)"
    site.require_module 'kramdown'


    # Création du fichier HTML
    debug "   * Création du fichier HTML"
    build_html_file || return

    # Création du fichier LaTex
    debug "   * Création fichier LaTex"
    build_latex_file || return

    # Compilation du fichier LaTex pour en faire un
    # document PDF
    compile_latex_file_to_pdf || return

    # On le propose en téléchargement
    fullpath_pdf.download

  end

  # Construction du fichier LaTex
  def build_latex_file
    if latex_folder.exist?
      debug "   * Destruction du dossier Latex provisoire."
      latex_folder.remove
    end
    latex_folder.build

    # CRÉATION DU FICHIER
    fullpath_latex.write total_latex_code

    if fullpath_latex.exist?
      debug "    = Fichier LaTex créé."
      flash "Fichier LaTex créé avec succès."
      return true
    else
      debug "    # Impossible de créer le fichier LaTex"
      return error "Le fichier LaTex n'a pas été créé…"
    end
  end

  # Produit le code complet pour un fichier LaTex intégral
  def total_latex_code
    <<-LATEX
\\documentclass[11pt,french,a4paper,openany]{book}
% Possibilité de mettre `twoside` et `a5paper` si on veut
% faire un petit format A5

% Packages utiles
\\usepackage[french]{babel}
\\usepackage{hyperref}
\\usepackage[utf8]{inputenc}
\\usepackage[OT1,T1]{fontenc}

\\begin{document}

#{kramdown_document.to_latex}

\\end{document}
    LATEX
  end

  # Fabrication du fichier HTML
  def build_html_file
    if fullpath_html.exist?
      debug "    * Destruction de l'ancien fichier HTML"
      fullpath_html.remove
    end

    # CRÉATION DU FICHIER
    fullpath_html.write kramdown_document.to_html

    if fullpath_html.exist?
      debug "   = Fichier HTML créé."
      flash "Fichier HTML créé avec succès."
      return true
    else
      debug "   * Impossible de créer le fichier HTML"
      return error "Le fichier HTML n'a pas pu être créé…"
    end
  end


  # Compilation du fichier LaTex en fichier PDF
  def compile_latex_file_to_pdf
    if fullpath_pdf.exist?
      debug "   * Destruction de l'ancien fichier PDF"
      fullpath_pdf.remove
    end
    cmd = "#{FOLDER_LATEX}/pdflatex \"#{affixe}.tex\" 2>&1"

    res = nil
    Dir.chdir(latex_folder.to_s) do
      res = `#{cmd}`
      res += `#{cmd}`
    end

    debug "Retour de la command pdflatex : #{res.inspect}"
    if fullpath_pdf_prov.exist?
      debug "   = Fichier PDF créé avec succès"
      debug "   * Déplacement du fichier PDF vers le dossier"
      FileUtils::mv fullpath_pdf_prov.to_s, fullpath_pdf.to_s
      latex_folder.remove
      return true
    else
      debug "   # Impossible de créer le fichier PDF"
      return error "Le fichier PDF n'a pas pu être créé (consulter le débug)"
    end
  end

  # {Kramdown::Document} Retourne le fichier kramdonw
  def kramdown_document
    @kramdown_document ||= begin
      Kramdown::Document::new(markdown_code_trim, {link_defs: @link_defs})
    end
  end

  # Prépare le code Markdown/Kramdown original pour la passer
  # par Kramdown. Notamment, il traite les liens par référence
  # qui ne sont pas du tout traités
  REG_REF_LINKS = /^\[(.+?)\]\w+(.+?)\w+"(.+?)"$/
  def markdown_code_trim
    @code = path_md.read
    @link_defs = Hash.new
    @code.gsub!(REG_REF_LINKS){
      link_id     = $1.freeze
      link_href   = $2.freeze
      link_title  = $3.freeze
      @link_defs.merge!(link_id => [link_href, link_title])
      ""
    }
    return @code
  end

  def fullpath_pdf
    @fullpath_pdf ||= fullpath_with_ext("pdf")
  end
  # Le fichier PDF, mais celui, provisoire, dans le
  # dossier latex_prov
  def fullpath_pdf_prov
    @fullpath_pdf_prov ||= latex_folder + "#{affixe}.pdf"
  end
  def fullpath_latex
    @fullpath_latex ||= latex_folder + "#{affixe}.tex"
  end
  def fullpath_html
    @fullpath_html ||= fullpath_with_ext('html')
  end
  def fullpath_affixe
    @fullpath_affixe ||= folder + affixe
  end
  def affixe
    @affixe ||= File.basename(path_md, File.extname(path_md))
  end
  def latex_folder
    @latex_folder ||= folder + 'latex_prov'
  end
  def folder
    @folder ||= SuperFile::new(File.dirname(path_md))
  end

  private
    def fullpath_with_ext ext
      folder + "#{affixe}.#{ext}"
    end
end

FileMD::new(param(:file) || param(:path)).to_pdf
redirect_to :last_route
