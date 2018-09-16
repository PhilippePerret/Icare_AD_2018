# encoding: UTF-8
class QuaiDesDocs
class << self

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'helper
  #
  # ---------------------------------------------------------------------
  def load_section name
    (folder_section + "#{name}.erb").deserb
  end
  def folder_section
    @folder_section ||= QuaiDesDocs.folder + "lib/section"
  end
  def formulaire_recherche  ; load_section 'formulaire_recherche' end
  def boite_navigation      ; load_section 'boite_navigation'     end
  def liste_documents       ; load_section 'liste_documents'      end

  # Contenu de l'accueil lorsqu'il est visité par un non icarien
  def section_non_icarien
    <<-HTML
<p class="big air">
  Nous sommes désolés, mais seuls les icariennes et icariens ont accès au <strong>Quai des docs</strong>.
</p>
<p class="right">
  #{'→ Postuler pour devenir icarienne ou icarien'.in_a(href: 'signup')}
</p>
    HTML
  end

  # Le message d'avertissement à placer au-dessus de toute liste de
  # documents et également dans un fichier "AVERTISSEMENT.txt" dans
  # les dossiers de téléchargement
  def avertissement
    <<-TXT
Veuillez bien noter, #{user.pseudo}, que ces documents sont strictement réservés à votre usage personnel au sein de l'atelier et ne doivent EN AUCUN CAS, sauf autorisation expresse de leurs auteures ou auteurs, être transmis à un tiers ou utilisés à vos propres fins.

Merci pour les auteures et auteurs, comme vous, qui ont produit ce travail relevant de la propriété intellectuelle.
    TXT
  end

  def avertissement_alessai_if_needed
    user.alessai? || (return '')
    nb = user.nombre_lectures
    nb_reste = 5 - nb
    s = nb > 1 ? 's' : ''
    (
      "En tant que simple icarien#{user.f_ne} à l’essai, vous n’êtes en mesure que de charger 5 documents du Quai des docs. " +
      "Vous êtes actuellement à #{nb} document#{s} téléchargé#{s}, il vous en reste donc <strong>#{nb_reste}</strong> à télécharger."
    ).in_div(id: 'warning_alessai', class: 'small italic red')
  end

end #/<< self
end #/QuaiDesDocs
