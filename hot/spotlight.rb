# encoding: UTF-8
=begin

Pour définir le coup de projecteur sur la page d'accueil.

Il suffit de :

  * Définir les données ci-dessous (en local)
  * S'assurer du bon aspect (en local)
  * Uploader ce seul fichier sur le site distant

La page d'accueil sera automatiquement actualisée.

=end
class SiteHtml
  # POUR DÉFINIR LE COUP DE PROJECTEUR COURANT
  # SPOTLIGHT = {
  #   href:     "analyse/31/show",
  #   title:    "COLLISION",
  #   before:   "Dernière analyse de film : ",
  #   after:    ""
  # }
  # ANALYSE DE FILM : analyse/31/show
  # PAGE NARRATION  : page/246/show?in=cnarration
  # SPOTLIGHT = {
  #   href:     "calculateur/main",
  #   title:    "CALCULATEUR DE STRUCTURE ?",
  #   before:   "Avez-vous déjà essayé le…<br>",
  #   after:    ""
  # }
  SPOTLIGHT = {
    href:     "quiz/12/show?qdbr=biblio",
    # img:      'divers/jorio2016.png',
    before:   "SEREZ-VOUS ASSEZ FORT#{user.f_e.upcase} pour<br>affronter le dernier…",
    title:    "Q U I Z&nbsp;&nbsp;&nbsp;&nbsp;F I L M<br>SPÉCIAL SPORT !",
    after:    ''
  }

end
