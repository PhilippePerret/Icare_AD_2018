# encoding: UTF-8
=begin
  Module qui envoie une demande de partage à un auteur
=end
raise_unless_identified

begin
  user.identified? || raise('Seul un icarien identifié peut accomplir cette action.')

  idocument = IcModule::IcEtape::IcDocument.new(site.current_route.objet_id)

  # On fait un ticket qui doit permettre
  #   1. de définir le partage d'un document
  #   2. de prévenir un icarien (ou Phil) que le partage a été défini
  #      après demande.
  ticket_code = "site.require_objet('ic_document');IcModule::IcEtape::IcDocument.new(#{idocument.id}).partager(request_user: #{user.id})"
  leticket = app.create_ticket(nil, ticket_code)

  request_message = <<-HTML
<p>Bonjour #{idocument.owner.pseudo},</p>
<p>Un(e) icarien(e) vient de vous soumettre une demande de partage pour votre document “#{idocument.original_name}”, qui n'est pas partagé.</p>
<p>Accepterez-vous de jouer le jeu de l'atelier Icare sur ce document (et la richesse que produit le partage de son travail) ?</p>
<p>Si oui, vous pouvez partager ce document simplement en cliquant sur le lien ci-dessous.</p>
<p>#{leticket.link 'Partager ce document (seulement avec les icariens)'}</p>
  HTML

  idocument.owner.send_mail(
    subject:        'Demande de partage de document',
    message:        request_message,
    force_offline:  false,
    formated:       true
  )
  flash "Demande de partage envoyée à #{idocument.owner.pseudo} pour son document “#{idocument.original_name}”.<br><br>Nous espérons vivement que cette demande sera entendue. Vous serez averti#{user.f_e} le cas échéant.<br><br>Un grand merci à vous."
rescue Exception => e
  debug e
  error e.message
ensure
  if param(:cr) && param(:cr) == 'quai_des_docs%2Fhome'
    redirect_to "quai_des_docs/home?an=#{param :an}&tri=#{param :tri}"
  else
    redirect_to :last_page
  end
end
