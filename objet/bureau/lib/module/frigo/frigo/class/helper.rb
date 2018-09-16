# encoding: UTF-8
class Frigo
class << self

  # Formulaire pour se logguer si l'on est un interlocuteur ou pour
  # s'enregistrer pour la première fois sur un fil.
  def form_login_signup_quidam
    (
      explication_login_signup.in_div(class:'tiny') +
      champ_operation_discussion  +
      champ_mail_interlocuteur    +
      champ_password              +
      bouton_ok_signup_form       +
      explication_inscription     +
      champ_pseudo                +
      app.fields_captcha
    ).in_form(id:'form_login_quidam', class: 'mg dix container', action: "bureau/#{frigo.owner_id}/frigo")
  end

  def bouton_ok_signup_form
    'OK'.in_submit(class:'btn btn-primary')
  end
  def champ_operation_discussion
    'create_of_retreive_discussion'.in_hidden(name:'operation')
  end
  def champ_mail_interlocuteur
    (param(:qmail)||'').in_input_text(name:'qmail', placeholder: 'Votre mail', style: 'width:400px').in_div
  end
  def champ_pseudo
    (param(:qpseudo)||'').in_input_text(name:'qpseudo', placeholder: 'Votre pseudo', style: 'width:400px').in_div
  end
  def champ_password
    (''.in_password(name: 'qpassword', placeholder: 'Code secret') + ' (au moins 6 caractères)'.in_span(class: 'tiny')).in_div
  end
  def explication_inscription
    <<-HTML
<p class='tiny'>Pour une inscription à une discussion avec #{frigo.owner.pseudo}, vous devez remplir ces deux champs supplémentaires (#{lien.aide(700, 'consulter l’aide')}) :</p>
<p class='tiny red'>Notez bien <strong class='red'>votre code secret</strong> et l'<strong class='red'>adresse mail associée</strong> car ils ne pourront pas vous être communiqués en cas d'oubli et la discussion serait définitivement perdue pour vous.
</p>

    HTML
  end
  def explication_login_signup
    <<-HTML
<p>
  <strong>Si vous êtes icarienne ou icarien</strong>, utilisez le #{lien.signin('formulaire normal')} d'identification pour suivre ou entamer la discussion avec #{frigo.owner.pseudo}.
</p>
<p>Si vous n'êtes pas icarien, <strong>indiquez ci-dessous votre mail et le mot de passe</strong> choisis pour entamer la discussion avec #{frigo.owner.pseudo}.
</p>
<p><strong>Pour amorcer une discussion</strong>, les 4 champs de ce formulaire doivent être renseignés (#{lien.aide(700, 'consulter l’aide')}).</p>
    HTML
  end

end #/<< self
end #/ Frigo
