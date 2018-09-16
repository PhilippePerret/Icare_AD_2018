# encoding: UTF-8
class MailMatcher

  # Erreur rencontrée au cours de la recherche, sur ce
  # mail
  attr_accessor :error

  # Liste d'erreurs trouvées
  attr_reader :errors

  # Méthode principale qui checke si le mail correspond
  # aux données envoyées par +hmatch+, les conditions pour
  # que le mail soit valide.
  #
  # RETURN true si le mail matche et false dans le cas
  # contraire.
  def match? hmatch
    if verbose
      puts "\n*** Test du message de titre #{subject} envoyé à #{to} (mode verbose)"
      puts "Paramètres : #{hmatch.inspect}"
    end
    @errors = Array.new
    # puts "Vérification d'un mail adressé à #{to}"
    message_strict = hmatch.delete(:message_strict)
    # puts "message_strict = #{message_strict.inspect}" if verbose
    subject_strict = hmatch.delete(:subject_strict)
    # Pour atteindre la propriété et la valeur attendue
    # dans l'exception levée
    prop      = nil
    expected  = nil
    hmatch.each do |pro, exp|
      prop      = pro
      expected  = exp
      if verbose
        # puts "Propriété #{prop.inspect} testée contre #{expected.inspect}"
      end
      case prop
      when :subject
        subject_match?(expected, subject_strict) || raise
      when :message
        message_match?(expected, message_strict) || raise
      when :message_has_tag, :message_has_tags
        matches_message_with_tags( message, expected ) || raise
      when :created_after, :created_before, :sent_after, :sent_before
        date_match?(prop, expected) || raise
      when :from
        from_match?(expected)  || raise
      when :to
        to_match?(expected)    || raise
      end
    end
  rescue Exception => e
    prop_value =
      case prop
      when :subject then subject
      when :message then message
      when :created_after, :sent_after, :created_before, :sent_before then created_at
      when :from then from
      when :to then to
      else "- valeur inconnue -"
      end
    @error = "Condition sur #{prop.inspect} échoue (devrait être #{expected.inspect}, est #{prop_value.inspect})"
    if verbose
      puts @error
    end
    return false
  else
    return true # Pour indiquer que le message est valide
  end

  # TRUE si le sujet correspond, FALSE sinon
  def subject_match? conditions, strict = false
    if strict
      subject == conditions
    else
      expect_string_to_be_in(subject, conditions)
    end
  end

  # TRUE si le message correspond, FALSE sinon
  def message_match? expected, strict = false
    res =
      if strict
        message_content === expected
      else
        expect_string_to_be_in(message_content, expected)
      end
    if verbose
      puts "Test du message : #{message_content.inspect}"
      puts "Valeur attendue : #{expected.inspect}"
      puts "Stricte ? #{strict.inspect}"
      puts "Résultat = #{res.inspect}"
    end
    return res
  end

  # TRUE si la date correspond, FALSE sinon
  def date_match? prop, expected
    if verbose
      puts "-------------"
      puts "Date d'envoi du mail : #{created_at.inspect} (#{created_at.as_human_date(true, true, ' ', 'à')})"
      puts "À comparer à : #{expected.inspect} (#{expected.as_human_date(true, true, ' ', 'à')})"
      puts "Comparaison : #{prop.inspect}"
    end
    res =
      case prop
      when :sent_after, :created_after
        created_at > expected
      when :sent_before, :created_before
        created_at < expected
      end
    if verbose
      puts "Résultat : #{res.inspect}"
      puts "-------------"
    end
    return res
  end

  # TRUE si l'expéditeur correspond, FALSE sinon
  def from_match? expected
    from == expected
  end

  # TRUE si le destinataire correspond, FALSE sinon
  def to_match? expected
    to == expected
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Méthode qui recherche +expected+ (Regexp, Array ou String) dans +str+
  # RETURN true si c'est OK ou false dans le cas contraire
  #
  # Pour qu'une recherche soit valide, il faut trouver tous les
  # segments fournis. Si un seul manque, la correspondance est
  # fausse.
  #
  def expect_string_to_be_in str, expected
    expected.instance_of?(Array) || expected = [expected]
    expected.each do |segment|


      # On transforme toujours le segment en expression régulière
      reg_segment =
        case segment
        when Regexp then segment.dup
        else /#{Regexp::escape segment}/i
        end

      if str.match(reg_segment)
        @errors << "Segment “#{segment.to_s}” trouvé."
      else
        # Le segment n'a pas été trouvé, on peut s'arrêter là
        @errors << "Segment “#{segment.to_s}” NON TROUVÉ."
        return false
      end
    end
    # Tous les segments ont été trouvés
    return true
  end

end #/MailMatcher
