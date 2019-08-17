# encoding: UTF-8
=begin

Extension String pour le traitement des documents Markdown

    >> "CITATION" AUTEUR - SOURCE

=end
class ::String

  # Traitements supplémentaires pour les document Markdown
  #
  # Fonctionnement :
  # La méthode découpe en paragraphe et parse chacun d'eux
  # en testant son amorce qui définit toujours une possibilité
  # de traitement.
  def extra_kramdown output_format = :html
    self.split("\n").collect do |line_init|
      line = line_init.strip
      case line
      when /^>>/ then line.kramdown_citations(output_format)
      when /^\[(.*?)\]$/ then line.kramdown_encart(output_format)
      else line_init
      end
    end.join("\n")
  end

  TEMPLATES_CITATIONS = {
    html: {
      sans_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span></span></div>",
      avec_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span> - <span class='source'>%{source}</span></span></div>"
    },
    latex: {
      sans_source: "\\citation_auteur{%{citation}}",
      avec_source: "\\citation_auteur[%{source}]{%{citation}}"
    }
  }
  def kramdown_citations output_format = :html
    matched = self.match(/>> ?"(.+?)" ?(.*?)(?: - (.*))?$/).to_a
    citation  = matched[1]
    auteur    = matched[2]
    source    = matched[3]
    key = source.nil? ? :sans_source : :avec_source
    template = TEMPLATES_CITATIONS[output_format][key]
    template % {citation: citation, auteur: auteur, source: source}
  end

  # Traitement des exergues
  REPLACEMENTS_PER_FORMAT = {
    html: {
      br: "<br />"
    },
    latex:{
      br:"---"
    }
  }
  def kramdown_encart output_format = :html
    str = (self[1..-2] || '').strip # pour enlever les croches
    replacement = REPLACEMENTS_PER_FORMAT[output_format][:br]
    str.gsub!(/\\n/, replacement)
    case output_format
    when :html
      str.in_div(class:'encart')
    else
      str
    end
  end

end
