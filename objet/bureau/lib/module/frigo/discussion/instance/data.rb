# encoding: UTF-8
class Frigo
class Discussion


  def user_pseudo   ; @user_pseudo  ||= get(:user_pseudo)   end
  def user_id       ; @user_id      ||= get(:user_id)       end
  def user_mail     ; @user_mail    ||= get(:user_mail)     end
  def options       ; @options      ||= get(:options)       end


  # ---------------------------------------------------------------------
  #   DATA PARAMÈTRES
  # ---------------------------------------------------------------------

  def qmail
    @qmail ||= param(:qmail).nil_if_empty
  end
  def qpseudo
    @qpseudo ||= param(:qpseudo).nil_if_empty
  end

  # ---------------------------------------------------------------------
  #   DATA VOLATILES
  # ---------------------------------------------------------------------

  def titre
    if frigo.owner?
      "Discussion #{shared_short_hmark} entre vous et #{interlocuteur_designation}"
    else
      "Discussion #{shared_short_hmark} entre #{frigo.owner.pseudo} et #{vous_when_not_owner}"
    end.in_h3
  end

  # Ça peut être "vous" si l'user est l'interlocuteur, mais si
  # c'est une discussion publique/semi-publique, ça peut être
  # autre chose
  def vous_when_not_owner
    if param(:qmail)
      'vous'
    else
      user_pseudo
    end
  end

  # Terme pour désigner l'interlocuteur, en fonction du
  # fait que c'est lui qui est connecté ou le propriétaire du
  # frigo
  def interlocuteur_designation
    @interlocuteur_designation ||= begin
      if frigo.owner?
        user_pseudo
      else
        if user.identified?
          user_pseudo
        else
          param(:qmail)
        end
      end
    end
  end

  def table ; @table ||= dbtable_frigo_discussions end

end #/Discussion
end #/Frigo
