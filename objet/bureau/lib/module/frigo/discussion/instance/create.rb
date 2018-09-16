# encoding: UTF-8
=begin

  Module pour la création d'une discussion

=end
class Frigo
class Discussion

  def create
    data_ok? || return
    @id = dbtable_frigo_discussions.insert(data_creation)
  end

  def data_creation
    now = Time.now.to_i
    umail, upseudo =
      if user.identified?
        [user.mail, user.pseudo]
      else
        [qmail, qpseudo]
      end
    cpassword =
      if user.identified?
        nil
      else
        require 'digest/md5'
        Digest::MD5.hexdigest("#{umail}#{param(:qpassword)}")
      end

    {
      owner_id:     frigo.owner_id, # note : correspond à frigo.id
      user_id:      user.identified? ? user.id : nil,
      user_mail:    umail,
      user_pseudo:  upseudo,
      cpassword:    cpassword,
      created_at:   now,
      updated_at:   now
    }
  end

  def data_ok?
    user.identified? && (return true)
    qmail != nil || raise('Il faut fournir un mail pour pouvoir vous prévenir des réponses et vous reconnaitre plus tard.')
    qpassword = param(:qpassword).nil_if_empty
    qpassword != nil || raise('Il faut fournir un mot de passe pour garder votre discussion confidentielle.')
    qpassword.length > 5 || raise('Le mot de passe doit faire au moins 6 caractères.')
    # Pseudo
    qpseudo != nil || raise('Il faut fournir un pseudonyme pour suivre cette conversation.')
    qpseudo.length < 21 || raise('Le pseudonyme ne doit pas excéder 20 caractères')
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end


end #/Discussion
end #/Frigo
