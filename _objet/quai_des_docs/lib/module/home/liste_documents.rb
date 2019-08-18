# encoding: UTF-8
=begin
  Module qui s'occupe de chercher les documents du trimestre courant
  et de les afficher.
=end
class QuaiDesDocs
class << self

  def listing_documents
    QuaiDesDocs.require_module 'listings'
    page.html_separator(40) +
    ul_documents_trimestre
  end

  def ul_documents_trimestre
    filtre = {
      created_between: [
        start_of_trimestre.to_i,
        end_of_trimestre.to_i
      ]
    }
    args = {
      infos_document: true,
      filtre:         filtre,
      key_sorted:     'time_original ASC',
      avertissement:  (annee_courante == annee_of_time && trimestre_courant == trimestre_of_time)
    }
    QuaiDesDocs.as_ul(args) || 'Aucun document pour ce trimestre'.in_p(class: 'big air')
  end

end #/<< self
end #/QuaiDesDocs
