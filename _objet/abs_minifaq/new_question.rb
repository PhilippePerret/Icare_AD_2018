# encoding: UTF-8
=begin

  Pour la soumission d'une nouvelle question mini-faq pour l'administrateur
  par un icarien actif.

=end
raise_unless_identified

question = param(:minifaq)[:question].nil_if_empty

if question.nil?
  error "Il faut indiquer la question, voyons ! ;-)"
else
  user.add_watcher(
    objet:      'abs_etape', objet_id: user.icetape.abs_etape.id,
    processus:  'reponse_minifaq', data: question
  )

  send_mail_to_admin(
    subject:    'Nouvelle question mini-faq',
    message:    (
      "Auteur   : #{user.pseudo} (##{user.id})\n" +
      "Date     : #{Time.now.to_i.as_human_date(true, true, ' ', 'à')}\n" +
      "Question :\n#{question}"
      ).in_pre,
    formated:   true
  )
  flash 'Merci pour votre question. Phil va y répondre le plus rapidement possible.'
end

redirect_to :last_page
