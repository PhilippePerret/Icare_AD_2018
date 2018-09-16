# encoding: UTF-8
=begin

=end
class AlreadySubmitForm < StandardError; end
class App

  # Méthode qui crée un numéro pour le formulaire, l'enregistre
  # dans la base de données :hot et retourne le champ hidden à
  # coller dans le formulaire
  #
  # +form_id+ Identifiant du formulaire associé. Il permet de
  # calculer le numéro en le combinant au mail de l'user
  #
  # On utilise ensuite la méthode `app.checkform_on_submit` pour
  # vérifier et détruire la donnée.
  #
  def checkform_hidden_field form_id
    require 'digest/md5'
    checksum = Digest::MD5.hexdigest("#{Time.now.to_i}#{form_id}#{session.session_id}")
    row = dbtable_checkform.get(where: {checksum: checksum}, colonnes: [:status])
    # Si on trouve déjà ce numéro dans la base, on indique que le formulaire
    # a déjà été créé
    if row != nil
      if row[:status] == 0
        # <= La page a été rechargée avant d'être soumise
      elsif row[:status] > 0
        # <= La page est rechargée après soumission
        raise AlreadySubmitForm, 'Merci de ne pas recharger la page !'
      end
    else
      # Sinon, on l'enregistre dans la table
      dbtable_checkform.insert(
        form_id:      form_id,
        session_id:   session.session_id,
        checksum:     checksum,
        status:       0,
        updated_at:   Time.now.to_i,
        created_at:   Time.now.to_i
      )
    end
    checksum.in_hidden(name:'__CHECKSUM', id: "__checksum-#{form_id}", class: '__checksum')
  end

  # Méthode à appeler avant de traiter le formulaire, qui va :
  #
  #   SOIT Détruire la donnée enregistrée et s'en retourner
  #        si la donnée existe (OK)
  #   SOIT Produire une erreur de formulaire déjà soumis dans
  #        le cas contraire (ERROR)
  #
  #  NOTES
  #     - Pour les formulaires "automatiques", on vérifie avant
  #       l'existence de __CHECKSUM dans les paramètres. Si on ne le
  #       trouve pas, c'est qu'il ne faut pas tester ce formulaire
  #
  def checkform_on_submit
    app.benchmark('-> checkform_on_submit')
    checksum = param(:__CHECKSUM)
    checksum != nil || (return true)
    if 0 == dbtable_checkform.count(where:{checksum: checksum})
      raise AlreadySubmitForm, 'Merci de ne pas recharger la page.'
    else
      # Sinon, on détruit la donnée pour ne pas pouvoir resoumettre
      # le formulaire.
      dbtable_checkform.delete(where:{checksum: checksum})
    end
    app.benchmark('<- checkform_on_submit')
  end

end #/App
