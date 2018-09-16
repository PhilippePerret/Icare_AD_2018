# encoding: UTF-8
class SiteHtml
class TestSuite
class TestUser < DSLTestMethod

  # Teste si l'user a reçu un mail
  def has_mail data_mail, inverse=false

    debug "-> has_mail(data_mail: #{Debug::escape data_mail}, inverse=#{inverse.inspect})"

    options = {}
    options.merge!(
      strict:     !!data_mail.delete(:strict),
      count:      data_mail.delete(:count),
      evaluate:   !!data_mail.delete(:evaluate)
    )

    ok          = nil
    is_success  = nil
    # Liste des messages d'erreur, if any.
    # Ce sera une liste des messages d'erreur rencontrés ou
    # restera à nil
    message_errors = nil
    subject_errors = nil

    # Pour recueillir les mails valides (pour tester leur
    # nombre)
    mails_ok = []

    # Pour le message de retour, pour spécifier le mail
    # qu'on doit trouver ou ne pas trouver.
    dmail_human = []
    data_mail[:subject] && begin
      sbj = data_mail[:subject].in_array.collect{|e| "“#{e}”"}.pretty_join
      dmail_human << "SUJET avec #{sbj}"
    end
    data_mail[:message] && begin
      msg = data_mail[:message].in_array.collect{|e| "“#{e}”"}.pretty_join
      dmail_human << "MESSAGE avec #{msg}"
    end
    dmail_human = dmail_human.pretty_join

    no_mails      = mails.empty?
    nombre_mails  = mails.count


    if nombre_mails == 0

      debug "  = aucun mail"

      if inverse == false && options[:count] != 0
        # Produit forcément un échec
        mess_retour = "Aucun mail n'a été envoyé à #{pseudo}."
        is_success = false
      else
        # Produit forcément un succès
        mess_retour = "Aucun mail n'a été envoyé à #{pseudo} (OK)."
        is_success = true
      end

      debug "  = is_success = #{is_success.inspect}"

    else

      # --------------------------
      # Si l'user a reçu des mails
      # --------------------------

      debug "  = #{pseudo} a reçu #{nombre_mails} mails."

      # Boucle sur chaque mail
      #
      # Si c'est un test droit (non inverse), on cherche un mail
      # qui contient tous les textes transmis. Si un mail ne
      # correspond pas, ça ne provoque pas forcément une erreur,
      # l'erreur ne tient qu'au fait qu'AUCUN mail ne correspond
      # à la recherche.
      # Si c'est un test inverse, on génère une erreur dès
      # qu'un mail correspond aux critères.
      mails.each do |dmail|

        tsujet    = TString.new(self, dmail[:subject])
        tmessage  = TString.new(self, dmail[:message])

        mail_is_ok = true

        data_mail.each do |k, v|

          debug "** Test propriété #{k.inspect} : #{Debug::escape v}"

          mail_is_ok = mail_is_ok &&
            case k
            when :sent_after, :send_after
              dmail[:created_at] > v
            when :sent_before, :send_before
              dmail[:created_at] < v
            when :message
              res = tmessage.has?(v, options)
              message_errors = tmessage.errors
              res
            when :subject, :sujet
              res = tsujet.has?(v, options)
              subject_errors = tsujet.errors
              res
            else
              error "La propriété #{k.inspect} est inconnue, je ne peux pas la tester… (je retourne true pour le moment) (#{__FILE__}:#{__LINE__})"
              true
            end

          debug "== mail_is_ok = #{mail_is_ok.inspect}"

          # Si c'est un test "droit" (non inverse) et qu'une
          # condition est false, on peut s'arrêter tout de
          # suite pour passer au mail suivant.
          # Mais ça n'est pas un échec pour autant, peut-être
          # qu'on trouvera le mail dans le mail suivant
          break if inverse == false && mail_is_ok == false

        end

        # Ce mail est OK, il remplit toutes les
        # conditions
        if mail_is_ok
          if inverse
            # Si c'est un test inverse, c'est-à-dire qu'il ne faut
            # pas trouver de mail et qu'un mail répond pourtant aux
            # conditions, il faut produire une failure et on peut
            # s'arrêter là

            # UN MAIL TROUVÉ => ÉCHEC INVERSE
            mess_retour = "Aucun mail n'aurait dû être trouvé avec les critères : #{dmail_human}."
            is_success = false

            break
          elsif options[:count] == nil || options[:count] == 1
            # Si c'est un test droit et qu'on cherche à
            # trouver seulement un mail, alors c'est un succès
            # et on peut s'arrêter là.

            # UN MAIL TROUVÉ => SUCCESS DROIT
            mails_ok << dmail
            mess_retour = "Un mail correspondant aux critères #{dmail_human} a été trouvé."
            is_success = true

            break
          else
            # Si c'est un test droit et qu'on cherche + d'1
            # message correspondant aux critères, alors on
            # doit continuer à chercher, en mémorisant ce mail.
            mails_ok << dmail
          end
        end

      end #/fin de boucle sur tous les mails

    end # /fin du else de "si no_mails"

    # Si c'est un test droit
    if inverse == false

      nombre_founds = mails_ok.count

      if options[:count].nil? && nombre_founds == 0
        # Si un seul mail était attendu mais qu'on ne
        # l'a pas trouvé, on produit un échec
        is_success = false
        mess_retour = "Aucun mail n'a été trouvé qui remplirait toutes les conditions : #{dmail_human}."

      elsif options[:count].to_i > 1
        # Si plusieurs mails sont attendus, on vérifie le nombre
        #  de mails.

        is_success = ( nombre_founds == options[:count] )
        s_mail = nombre_founds > 1 ? 's' : ''

        mess_retour =
        if is_success

          # NOMBRE DE MAILS TROUVÉS => SUCCESS DROIT MULTIPLE
          "#{nombre_founds} mail#{s_mail} trouvé#{s_mail} répondant aux critères #{dmail_human}."

        else

          # PAS NOMBRE DE MAILS TROUVÉS => ÉCHEC DROIT MULTIPLE
          "On devrait trouver #{options[:count]} mails répondant aux critères #{dmail_human}. Seulement #{nombre_found} trouvé#{s_mail}."

        end

      end #/EN fonction de options[:count]

    end #/ si inverse == false

    debug "  Fin de test des mails"

    if is_success === nil
      raise("is_success ne devrait pas être nil (#{__FILE__}:#{__LINE__})…")
    end
    debug "  = is_success = #{is_success.inspect}"
    if mess_retour == nil
      raise "Le message de retour `mess_retour` devrait être défini."
    end

    debug " = mess_retour: #{mess_retour.inspect}"

    options[:evaluate] && ( return is_success )

    # Production du cas
    SiteHtml::TestSuite::Case::new(
      self,
      result:   is_success,
      message:  mess_retour
    ).evaluate

  end


  def has_not_mail(data_mail); has_mail(data_mail true) end
  def has_mail?(data_mail); has_mail(data_mail.merge(evaluate: true)) end
  def has_not_mail?(data_mail); has_mail(data_mail.merge(evaluate: true), true) end

  # Tous les mails de l'auteur.
  # C'est un Array de Hash contenant les données des mails tels
  # qu'enregistrés dans le dossier `tmp/mails`
  def mails
    @mails ||= begin
      Dir["./tmp/mails/**/*.msh"].collect do |pmail|
        dmail = Marshal.load(SuperFile::new(pmail).read)
        dmail[:to] == data[:mail] ? dmail : nil
      end.compact
    end
  end

end #/TestUser
end #/TestSuite
end #/SiteHtml
