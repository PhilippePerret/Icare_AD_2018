# encoding: UTF-8
=begin

  Processus pour :
    - répondre à une question pour la minifaq
    - répondre simplement à l'icarien
    - supprimer la question minifaq
=end

# Si c'est une question destinée à la minifaq (= que Phil a jugé destinée
# à la minifaq) on indique à l'auteur qu'il peut la retrouver sur son étape
# de travail.
def supplement_si_question_minifaq
  if pour_minifaq?
    lien_minifaq = lien.bureau('mini-faq de votre étape', online: true)
    "Vous pouvez également retrouver cette réponse dans la #{lien_minifaq}.".in_p
  else
    ''
  end
end

# Si la question est à détruire, rien n'est à faire
if pour_suppression?
  no_mail_user
  flash "Question détruite."
elsif pour_auteur?
  # Rien à faire, le mail lui sera envoyé avec la réponse
  flash "Réponse envoyée à #{owner.pseudo}."
else
  # === POUR MINIFAQ ===
  # On doit enregistrer la question dans la minifaq
  now = Time.now.to_i

  # Le contenu de la question/réponse, mis en forme
  content =
    owner.pseudo.in_div(class: 'mf_auteur') +
    question.in_div(class: 'mf_question') +
    reponse.in_div(class: 'mf_reponse')

  data_qr = {
    abs_etape_id:   objet_id,
    abs_module_id:  absetape.module_id,
    numero:         absetape.numero,
    question:       question,
    reponse:        reponse,
    content:        content,
    user_id:        owner.id,
    user_pseudo:    owner.pseudo,
    created_at:     now,
    updated_at:     now
  }
  qr_id = dbtable_minifaq.insert(data_qr)

  flash "Réponse enregistrée pour la mini-faq de l'étape (##{qr_id})."
end
