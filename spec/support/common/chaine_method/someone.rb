# encoding: UTF-8

# Classe principale pour la personne
class Someone

  attr_reader :chaine
  attr_reader :pseudo
  attr_reader :user_id

  def initialize pseudo_or_data, chaine
    @chaine = chaine
    case pseudo_or_data
    when String
      @pseudo = pseudo_or_data
    when Hash
      pseudo_or_data.each{|k,v|instance_variable_set("@#{k}", v)}
    else
      raise 'Le premier argument doit être le pseudo (String) ou un Hash de données (contenant au moins :user_id).'
    end
  end

  def auser
    @auser ||= User.new(user_id)
  end

  def evaluate
    auser.respond_to?(chaine.method_name.to_sym) || begin
      raise "User ne répond pas à la méthode d'instance #{chaine.method_name}…"
    end
    @message_success = chaine.options ? chaine.options.delete(:success) : nil
    if chaine.args
      if chaine.options
        auser.send(words_chaine, chaine.args, chaine.options)
      else
        auser.send(words_chaine, chaine.args)
      end
    else
      auser.send(words_chaine)
    end
    # L'action pouvait être soit une action à faire (clic sur un bouton, etc.) soit
    # un test (réception de mail). On le définit de deux manières : s'il y a un
    # message de succès ou si la commande est reconnue comme une commande de test
    # alors on la traite comme un test, sinon on la traite comme une action.
    if @message_success || words_chaine_is_test?
      success @message_success
    else
      _action "#{pseudo || auser.pseudo} #{message_action_humain}."
    end
  end

  def message_action_humain
    m = chaine.words.reverse.join(' ')
    case chaine.args
    when Hash
      chaine.args.key?(:in) && m += " dans #{chaine.args.delete(:in)}"
    when String
      m += " “#{chaine.args}”"
    else
      m += chaine.args.inspect
      chaine.instance_variable_set("@args", nil)
    end

    if chaine.options.nil_if_empty
      chaine.options.key?(:in) && m += " dans #{chaine.options.delete(:in)}"
      chaine.options.empty?   || m += " (#{chaine.options.inspect})"
    end
    return m
  end

  def words_chaine
    @words_chaine ||= chaine.method_name.to_sym
  end

  def words_chaine_is_test?
    case words_chaine
    when :recoit_le_mail, :ne_recoit_pas_le_mail
      true
    else
      false
    end
  end
end
# ---------------------------------------------------------------------
#   Visiteurs possible
def Phil chaine
  @Phil = Someone.new({user_id: 1, pseudo: 'Phil'}, chaine)
  @Phil.evaluate
end
def Benoit chaine
  @Benoit = Someone.new({user_id: 50, pseudo: 'Benoit'}, chaine)
  @Benoit.evaluate
end
