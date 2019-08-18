# encoding: UTF-8
=begin
Méthodes pour les taches
=end
class SiteHtml
class Admin
class Console

  class Images
  class << self

    def sub_log mess
      console.sub_log mess
    end

    def balise_image relpath
      relpath = relpath.nil_if_empty

      if relpath.nil?
        # => Il faut donner la syntaxe
        mess = <<-HTML
@syntaxe (console)

    balise image &lt;path/to/image.ext&gt;[ erb]

    Path relatif à partir de ./_view/img/
    Ou pour Narration : ./data/unan/pages_semidyn/cnarration/img/

    Si `erb` (ou `ERB`) à la fin, c'est une balise ERB
    qui est retournée.

POUR INSÉRER UN LIEN DANS UNE PAGE :

    IMAGE[path/to/image|title ou position|legend|subfolder]

    Seul le path est une donnée obligatoire.
    Il peut se trouver, dans l'ordre :
      1. Tel quel (le path fourni est le path depuis la base du site)
      2. Dans le dossier image du site : ./_view/img/
      3. Dans le dossier narration : ./unan/pages_demisyn/cnarration/img
      4. Dans un dossier livre si `subfolder` est fourni
      5. Dans le dossier analyses : ./data/analyse/image/
      6. Dans un dossier d'une analyse si `subfolder` est fourni.

    Si title est :
      - inline  => image inline
      - fright  => flottant à droite
      - fleft   => flottant à gauche
      - plain   => 100%
      - autre chose => Un titre alternatif (qui pourra aussi servir
      de légende)

    Ce deuxième paramètre peut se terminer par un pourcentage à
    indiquer, par exemple : 'inline 80%' pour indiquer la taille
    que doit occuper l'image.

    Si légende est :
      - nil (vraiment non défini, donc sans le "|") => pas de légende
      - "null" => pas de légende (utile pour quand il y a un sous-dossier)
      - "=" => le titre est mis en légende
      - explicitement définie après le "|"

        HTML

        sub_log mess.in_pre
      else
        # => Il faut donner la balise
        relpath, fin = relpath.split(' ')
        # Afin d'éviter les erreurs bêtes, on signale une erreur si
        # l'image n'existe pas.
        fullpath = "./_view/img/#{relpath}"
        if File.exist?(fullpath)
          # res = image(relpath)
          res = "IMAGE[#{relpath}]"
          res = "<%= #{res} %>" if fin.to_s.downcase == 'erb'
          res = "<input type='text' value='#{res}' onfocus='this.select()' />"
        else
          res = "L'image de path `#{fullpath}` est inconnue."
        end
        sub_log res
      end
      ""
    end
  end #/<< self
  end #/Images
end #/Console
end #/Admin
end #/SiteHtml
