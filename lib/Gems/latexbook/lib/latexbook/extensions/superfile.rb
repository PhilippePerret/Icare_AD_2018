# encoding: UTF-8
=begin

Extension de la class SuperFile

=end
class SuperFile

  # Correction opérées après avoir "kramdowné" le code du
  # fichier Markdown et produit le fichier LaTex (c'est le
  # code de ce fichier LaTex qui est modifié ici)
  def corrections_latex
    code = self.read

    # Pour que les listes de définition s'affichent bien
    # c'est-à-dire avec la définition sous le mot
    # Car kramdown ne met pas de \hfill \\ donc la définition
    # se met au même niveau que le mot défini.
    code.gsub!(/\\item\[(.*?)\]/){
      "\\item[#{$1}] \\hfill \\\\\n"
    }

    self.write code
  end

end #/SuperFile
