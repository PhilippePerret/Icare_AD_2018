# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Permet d'afficher le document comme une carte, lorsqu'il n'est
  # pas un formulaire pour télécharger le document.
  # Par exemple, c'est valable lorsque le document n'est pas
  # partagé et qu'il est affiché sur le quai des docs, avec un lien
  # pour inviter l'auteur à le partager.
  #
  def as_card options = nil
    (
      owner.pseudo.in_div(class: 'doc_auteur') +
      (
        image('icones/document_pdf.png', class: 'doc_img') +
        original_name.in_span(class: 'doc_name') +
        avertissement_non_partage_et_demande
      ).in_div(class: 'doc_div')

    ).in_div(class: 'like_form_download')
  end
  # Renvoie un div à ajouter à la carte pour préciser que
  # ce document n'est pas partagé et un lien pour faire la
  # demande à l'auteur
  def avertissement_non_partage_et_demande
    (
      'Document non partagé. Faites la demande de partage à l’auteur en cliquant sur le bouton ci-dessous.'
    ).in_div(class: 'warning') +
    "Demander à #{owner.pseudo} de partager son document".in_a(href: "ic_document/#{id}/share_request?an=#{param(:an)}&tri=#{param :tri}&cr=#{CGI.escape site.current_route.route}", class:'btn small').in_div(class: 'right')
  end

  # Pour obtenir un texte du type :
  # "document “mon beau document” de Lauteur (étape 10 du module suivi)"
  #
  def designation
    s = "document “#{original_name}”"
    owner.id == user.id || s << " de #{owner.pseudo}"
    if icmodule_id != nil && icetape_id != nil
      s << " (étape #{icetape.numero} du module “#{icmodule.abs_module.name}”)"
    end
    return s
  end

end #/IcDocument
end #/IcEtape
end #/IcModule
