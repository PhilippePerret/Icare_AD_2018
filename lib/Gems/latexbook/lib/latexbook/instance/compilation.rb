# encoding: UTF-8
=begin

Module qui contient les méthodes de compilation du livre latex

=end
class LaTexBook

  # Attention, ça ne fonctionnera pas sur le site distant
  TEXLIVE_FOLDER = "/usr/local/texlive/2015/bin/x86_64-darwin/"

  # = main =
  #
  # Méthode principale qui compile le livre
  #
  def compile
    Dir.chdir("#{LaTexBook::compilation_folder}") do
      # suivre_exec "latex main.tex"
      suivre_exec "pdflatex main.tex"
      suivre_exec "biber main.tex"
      # suivre_exec "latex main.tex"
      suivre_exec "pdflatex main.tex"
      suivre_exec "makeindex main.idx"
      suivre_exec "pdflatex main.tex"
      suivre_exec "pdflatex main.tex"
      # suivre_exec "dvips main.dvi"
    end
  end

  def suivre_exec command
    res = `#{TEXLIVE_FOLDER}#{command} 2>&1`.force_encoding('utf-8')
    log "Commande exécutée : #{command}"
    log "Résultat commande : #{res}"
  end

end #/LatexBook
