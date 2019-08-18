# encoding: UTF-8
class AbsModule
class AbsEtape

  # {String} Code HTML pour l'affichage des documents du QDD de l'étape
  # courante.
  def qdd_formated
    introduction = 'Le “Quai des docs” vous permet de consulter tous les documents produits au sein de l’atelier <strong>sur cette étape de travail en particulier</strong>.'.in_p(class: 'small italic')
    # On regarde rapidement s'il y a des documents à utiliser. S'il y en a,
    # on charge ce qu'il faut du quai des docs. Mais comme la méthode
    # `has_documents_qdd?` ne semble pas très sûr, on teste aussi le retour
    # de as_ul
    listing_docs =
      if has_documents_qdd?(strict = false)
        site.require_objet 'quai_des_docs'
        QuaiDesDocs.require_module 'listings'
        listing_documents_qdd = QuaiDesDocs.as_ul(filtre: {etape: self.id}, avertissement: true, all: true)
        if listing_documents_qdd
          # S'il y a des documents pour cette étape
          listing_documents_qdd +
          ''.in_div(style:'clear:both')
        end
      end
    introduction +
    (listing_docs || "Pour le moment, aucun document n’a été produit ou partagé pour cette étape en particulier.".in_p)
  end

end #/IcEtape
end #/IcModule
