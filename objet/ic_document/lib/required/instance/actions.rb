# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument


  # Méthode pour forcer le partage d'un document (original et
  # comments).
  # Cette méthode a été initiée pour permettre à un ticket
  # de partager un document depuis un mail.
  #
  # +opts+
  #   original        {Fixnum} Valeur de partage pour le document
  #                   original (1: partagé, 2: non partagé)
  #                   1 par défaut
  #   comments        {Fixnum} Valeur de partage pour le document
  #                   commentaires (1: partagé, 2: non partagé)
  #                   1 par défaut
  #   request_user    {Fixnum} L'ID de l'user qui a fait la
  #                   demande, pour pouvoir l'avertir du partage.
  #
  def partager opts

    bitoshared = opts[:original] || 1
    bitcshared = opts[:comments] || 1

    # (Re)définir le partage du document
    new_options = self.options
    debug "Options avant : #{self.options}"
    new_options = new_options.set_bit(4, 1)
    new_options = new_options.set_bit(12, 1)
    new_options = new_options.set_bit(1, bitoshared)
    new_options = new_options.set_bit(9, bitcshared)
    self.set(options: new_options)
    debug "Options après : #{new_options}"

    # Il faut avertir le demandeur que sa requête a été
    # entendue si un icarien est à l'origine de la demande
    # de partage.
    if opts.key?(:request_user)
      lien = "#{site.domain_url}/quai_des_docs/home?an=#{annee}&tri=#{trimestre}"
      lien = 'le Quai des docs'.in_a(href: lien)
      requser = User.new(opts[:request_user])
      message = <<-HTML
<p>Bonjour #{requser.pseudo},</p>
<p>#{owner.pseudo} a bien entendu votre demande de partage du document “#{original_name}”.</p>
<p>Vous pouvez maintenant le télécharger et le lire depuis #{lien} <span class='warning'>après vous être identifié#{requser.f_e}</span>.</p>
<p>Bonne lecture</p>
      HTML
      requser.send_mail(
        subject:    'Votre demande de partage a été entendue',
        message:    message,
        formated:   true
      )
    end

    # Message final pour remercier ou dire dommage
    ajout =
      if bitoshared == 2 && bitcshared == 2
        "Il est juste dommage que vous ne les partagiez pas ou plus.<br />Avez-vous pris connaissance de #{lien.aide(30, titre:'la raison du partage')} ?"
      else
        'Un grand merci à vous pour le partage de votre travail !'
      end
    flash "#{owner.pseudo}, le niveau de partage de votre document “#{original_name}” vient d'être défini. #{ajout}"

  rescue Exception => e
    debug e
    error e
  end

  # Pour downloader le document de travail (pas le document QDD)
  #
  # Rappel : le document se trouve toujours dans le dossier :
  #   ./tmp/download/user-<id user>/ (cf. ci-dessous)
  def download_original ; path_download_file(:original).download end
  def download_comments ; path_download_file(:comments).download end

  def path_download_file ty = :original
    folder_download + "#{doc_affixe}#{ty == :original ? '' : '_comsPhil'}.#{extension}"
  end

  def folder_download
    @folder_download ||= site.folder_tmp + "download/user-#{user_id}"
  end


end #/IcDocument
end #/IcEtape
end #/IcModule
