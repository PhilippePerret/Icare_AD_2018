# encoding: UTF-8
=begin

  Les bits d'options de 0 à 15 sont réservés à l'administration
  et les bits de 16 à 31 sont réservés à l'application elle-même.

  C'est ici qu'on définit ces options propres à l'application.

  Exemple de réglage forcé des options
  ------------------------------------

  options = '0'*26
  options[0]  = '0' # > 0 si administrateur
  options[1]  = '0' # Grade de l'user
  options[2]  = '1' # 0 si le mail n'a pas été confirmé
  options[3]  = '1' # 1 si a été détruit
  options[4]  = '9' # Type de contact (voir aussi ci-dessous)
                    # 9 => aucun mail
  options[16] = '4' # État de l'icarien
                    # 4 => inactif
                    # Si 1, pas reçu, si 2 actif, 3 en pause
  options[17] = '1' # jamais de mails
  options[18] = '0' # Direction après identification
  options[19] = '8' # Type de contact pour les autres icariens
  options[20] = '0' # pour cacher l'header
  options[21] = '1' # pour partager son historique
  options[22] = '1' # Notifier si reçoit message
  options[23] = '8' # Type de contact pour le reste du monde

=end
class User

  # Bit 16
  # État de l'icarien
  def bit_state
    options[16].to_i
  end

  # Bit 17 et suivant, cf. le fichier
  #  ./ruby/_objets/User/model/Preferences/preferences.rb dans
  # l'atelier Icare_AD
  # Le bit 17 (18e) peut prendre les valeurs :
  #   0: rapport quotidien si actif
  #   1: jamais de mails
  #   2: résumé hebdomadaire
  #   3: quotidien et rapport hebdomadaire
  def pref_mails_activites ; options[17].to_i end # bit 17 (= 18e)

  # Une valeur de 0 à 9 (voir plus) définissant où l'user
  # doit être redirigé après son login. Ces valeurs peuvent être
  # définies par l'application, dans REDIRECTIONS_AFTER_LOGIN
  # dans la fichier site/config
  # avec en clé le nombre du bit 18 :
  #   site.redirections_after_login = {
  #     '1' => {hname: "<nom pour menu>", route: 'route/4/show'},
  #     '2' => etc.
  #   }
  def pref_goto_after_login; options[18].to_i end # bit 18 (= 19e)

  # = Type de contact =
  # Pour les autres icariens
  #   0:  Par mail et par message (frigo)
  #   1:  Par mail seulement
  #   2:  Par message seulement
  #   8:  Aucun contact
  def pref_type_contact; options[19].to_i end
  # Pour le reste du monde (non icariens)
  #   0:  Par mail et par message (frigo)
  #   1:  Par mail seulement
  #   2:  Par message seulement
  #   8:  Aucun contact
  def pref_type_contact_world; options[23].to_i end

  def pref_cache_header?        ; pref? 3 end # bit 20
  def pref_share_historique?    ; pref? 4 end # bit 21
  def pref_notify_when_message? ; pref? 5 end # bit 22

  def pref? relbit
    realbit = 17 + relbit
    options[realbit].to_i == 1
  end

  # BIT 24 (25e)
  def bit_reality
    options[24].to_i
  end

  # BIT 25 (26e)
  # Bit d'avertissement d'échéance de paiement dépassée
  # C'est un nombre de 0 à 9 pour savoir quel mail a été envoyé
  # suite à une échéance de paiment dépassé
  # 1: simple avertissement jusqu'à 9: menace de rejet
  # Note : les mails sont gérés par le CRON
  def bit_echeance_paiement
    options[25].to_i
  end


end
