# encoding: UTF-8
=begin

  Bloc de l'accueil présentant les questions les plus fréquentes
  posées sur l'atelier.

=end
class FaqAtelier
class << self

  LIEN_MODULES    = "☛ Les modules".in_a(href: 'modules')
  LIEN_REUSSITES  = "☛ section “réussites”".in_a(href: 'overview/reussites')
  DATA_FAQ = [
    {
      question: 'À qui s’adresse l’atelier Icare ?',
      reponse: "À toute personne voulant écrire, apprentie ou non, complète débutante ou non. L'apprentissage ou l'accompagnement sont adaptés au niveau de chacun."
    },
    {
      question: 'Qu’est-ce qui distingue l’atelier Icare des autres formations en ligne ?',
      reponse: "Ça n’est pas une épicerie… Ça n’est pas un journaliste qui l’anime mais un véritable auteur édité à compte d’éditeur, scénariste professionnel et pédagogue passionné et créatif."
    },
    {
      question: 'Est-ce que l’atelier permet de devenir scénariste ?',
      reponse: "Tout à fait, et même auteur au sens large, comme vous pouvez le constater dans la #{LIEN_REUSSITES} du site."
    },
    {
      question: 'Peut-on développer son propre projet ?',
      reponse: "Tout à fait. Il y a deux types de modules : ceux qui accompagnent un projet et ceux qui permettent d'apprendre la dramaturgie (#{LIEN_MODULES})."
    },
    {
      question: 'Comment se déroule le travail à l’atelier ?',
      reponse: "Le plus éclairant, pour le savoir, est de <a href='overview/parcours'>suivre le parcours fictif de trois icariens</a>."
    },
    {
      question: 'Est-ce qu’on fait des exercices d’écriture ?',
      reponse: "Oui pour ce qui est des modules consacrés à l’apprentissage proprement dit, qui sont pensés pour stimuler la créativité sur la base d'exercices."
    },
    {
      question: 'Quels sont les modules proposés ?',
      reponse: "Il suffit de cliquer le bouton “Modules proposés” ci-dessus pour le savoir."
    }
  ]

  def frequently_asked_questions
    (
      'Questions les plus fréquentes'.in_div(class: 'titre') +
      DATA_FAQ.collect do |qr|
        qr[:question].in_div(class:'question') +
        qr[:reponse].in_div(class:'reponse')
      end.join('')
    ).in_div(id: 'faq')
  end
end #/<< self
end #/Home
