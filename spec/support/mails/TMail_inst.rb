# encoding: UTF-8
defined?(VERBOSE) || VERBOSE = false

class TMail

  # Le nom du fichier contenant les données du mail
  attr_reader :fname

  # L'expéditeur et le récepteur du mail
  attr_reader :to, :from

  # {Integer} La date d'envoi du mail (timestamp)
  attr_reader :sent_at

  # Respectivement : le sujet tel que transmis au mail, le sujet avec l'entête
  # éventuelle (p.e. "[ICARE] ") et le mail formaté, avec les caractères unicode
  # transformés.
  attr_reader :subject, :full_subject, :fsubject

  # Respectivement : le message original envoyé, le message final formaté
  attr_reader :message, :fmessage

  # Ce qui fait que le mail n'a pas été retenu
  attr_reader :errors

  # Instanciation du mail, à partir des données récupérées dans
  # le fichier YAML de ./tmp/mails/
  def initialize dmail, fname
    @fname  = fname
    @data   = dmail
    dmail.each { |k, v| instance_variable_set("@#{k}", v)}
  end

  # Méthode qui retourne true si le mail correspond aux données de la
  # table +hdata+
  def matches? hdata
    @errors = [] # pour mettre les problèmes rencontrés par rapport aux attentes
    hdata[:to]            && notSentTo?(hdata[:to])                   && raise
    hdata[:from]          && notSentBy?(hdata[:from])                 && raise
    hdata[:after]         && notSentAfter?(hdata[:after])             && raise
    hdata[:before]        && notSentBefore?(hdata[:before])           && raise
    hdata[:subject]       && notHasSubject?(hdata[:subject])          && raise
    hdata[:fsubject]      && notHasFSubject?(hdata[:fsubject])        && raise
    hdata[:full_subject]  && notHasFullSubject?(hdata[:full_subject]) && raise
    hdata[:content]       && notContents?(hdata[:content])            && raise
    hdata[:fcontent]      && notFContents?(hdata[:fcontent])          && raise
    return true
  rescue Exception => e
    if e.message.length > 0
      raise e
    end
    return false
  end

  # Pour retourner toutes les données du mail
  def all_data
    self.data
  end

  # ---------------------------------------------------------------------
  # Méthodes de check
  def notSentTo?(cto)
    ok = @to.match(/(^|<)#{Regexp.escape(cto)}(>|$)/)
    ok || @errors << "Mauvais récepteur (attendu : #{cto}, actuel : #{@to})"
    !ok
  end

  def notSentBy?(cfrom)
    ok = self.from.match(/(^|<)#{Regexp.escape(cfrom)}(>|$)/)
    ok || @errors << "Mauvais expéditeur (attendu : #{cfrom}, actuel : #{self.from})"
    !ok
  end

  def notSentAfter?(time)
    time.is_a?(Integer) || time = time.to_i
    ok = self.sent_at > time
    ok || @errors << "Envoyé avant #{time}"
    !ok
  end

  def notSentBefore?(time)
    time.is_a?(Integer) || time = time.to_i
    ok = self.sent_at < time
    ok || @errors << "Envoyé après #{time}"
    !ok
  end

  def notHasSubject?(csuj)
    ok = self.subject.match(/#{Regexp.escape(csuj)}/)
    ok || @errors << "Le sujet ('#{self.subject}') ne contient pas '#{csuj}'"
    !ok
  end

  def notHasFSubject?(csuj)
    ok = self.fsubject.match(/#{Regexp.escape(csuj)}/)
    ok || @errors << "Le sujet formaté ('#{self.fsubject}') ne contient pas '#{csuj}'"
    !ok
  end

  def notHasFullSubject?(csuj)
    ok = self.full_subject.match(/#{Regexp.escape(csuj)}/)
    ok || @errors << "Le sujet complet ('#{self.full_subject}') ne contient pas '#{csuj}'"
    !ok
  end

  def notContents?(searched)
    !contains(searched)
  end
  def contains?(searched)
    searched.is_a?(Array) || searched = [searched]
    searched.each do |s|
      content_brut.match(/#{Regexp.escape(s)}/) || begin
        @errors << "Texte non trouvé dans le message : '#{s}'"
        return false
      end
    end
    return true
  end

  def notFContents?(searched)
    !fcontains?(searched)
  end

  def fcontains?(searched)
    searched.is_a?(Array) || searched = [searched]
    searched.each do |s|
      fmessage.match(/#{Regexp.escape(s)}/) || begin
        @errors << "Texte non trouvé dans le message formaté : '#{s}'"
        return false
      end
    end
    return true
  end

  # ---------------------------------------------------------------------
  # Propriétés volatiles
  def content_brut
    @content_brut ||= @message.gsub(/<(.+?)>/)
  end

end
