# encoding: UTF-8
=begin

  Module de toutes les méthodes qui gèrent l'aspect des
  autorisations de l'user

  Elles travaillent avec la table :hot, 'autorisations'.

=end
class User

  # Niveau d'autorisation
  #
  # Pour le moment, cette donnée n'est pas encore utilisé, elle
  # est définie lorsque l'on obtient une autorisation par IP, comme
  # pour le module LINKS ANALYZER qui a besoin d'avoir un accès complet
  # aux page de narration.
  # Cette valeur correspond à la valeur d'administration.
  def authorization_level
    # Si le niveau d'autorisation n'est pas encore défini, c'est que
    # ce niveau a été appelé avant la méthode authorized? qui le
    # définit. On l'appelle donc pour le définir.
    authorized? if @authorization_level === nil
    @authorization_level
  end
  def authorization_level= value; @authorization_level = value end

  # Requiert tous les modules utiles aux autorisations compliquées
  def require_modules_autorisation
    site.require_module('User_autorisation')
  end

  # Retourne true si l'user possède une autorisation qui
  # couvre la date courante
  def authorized?
    if @is_authorized === nil
      if authorized_by_ip?
        @is_authorized = true
      else
        identified? || ( return false )
        @is_authorized =
          if admin? || moteur_recherche?
            true
          elsif authorized_from.nil? || authorized_upto.nil?
            # Sera calculé après par le patch ci-dessous
            false
          else
            (authorized_from <= Time.now.to_i && authorized_upto > (Time.now.to_i + 30))
          end

        # Patch d'autorisation en attendant que tous les autorisés
        # soient corrigés
        @is_authorized ||= patch_modification_users
      end
    end
    @is_authorized
  end

  # Si le paramètre :authips se trouve dans le query-string (donc dans les
  # params), le programme regarde si l'IP de l'user courant est une des
  # IPs autorisées. Si c'est le cas, il lui donne toutes les autorisations
  # (MAIS NE LE LOGGUE PAS, DONC ÇA N'EST VALABLE QUE POUR UNE SEULE PAGE)
  def authorized_by_ip?
    param(:authips) == '1' || ( return false )
    # debug "Test de l'autorisation par IP"
    File.exist?('./data/secret/authorized_ips.rb') || (return false)
    require './data/secret/authorized_ips'
    # La valeur de AUTHORIZED_IPS[user.ip] est un nombre, 9 pour
    # grand manitou.
    if AUTHORIZED_IPS.key?(self.ip)
      @authorization_level = AUTHORIZED_IPS[self.ip]
      true
    else
      false
    end
  end

  # RETURN la valeur de @is_authorized
  #
  def patch_modification_users
    debug "-> patch_modification_users"
    require_modules_autorisation
    return do_patch_modification_users
  end

  def reset_autorisations
    @is_authorized   = nil
    @authorized_from = nil
    @authorized_upto = nil
  end

  # Retourne la date de début de l'autorisation courante
  def authorized_from
    @authorized_from ||= begin
      drequest = {
        where: "user_id = #{id} AND start_time IS NOT NULL",
        colonnes: [:start_time],
        order: 'start_time DESC',
        limit: 1
      }
      firstauto = table_autorisations.select(drequest).first
      if firstauto.nil?
        nil
      else
        firstauto[:start_time]
      end
    end
  end
  # Retourne la date de fin de la dernière autorisé
  def authorized_upto
    @authorized_upto ||= begin
      drequest = {
        where: "user_id = #{id} AND end_time IS NOT NULL",
        colonnes: [:end_time],
        order: 'end_time DESC',
        limit: 1
      }
      last = table_autorisations.select(drequest).first
      if last.nil?
        nil
      else
        last[:end_time]
      end
    end
  end

  # Retourne true si l'user possède une autorisation à vie
  def autorisation_a_vie?
    drequest = {where: "user_id = #{id} AND start_time IS NOT NULL AND end_time IS NULL"}
    table_autorisations.count(drequest) == 1
  end

  # Méthode qui ajoute des jours d'autorisation à l'user
  #
  def add_jours_abonnement args
    require_modules_autorisation
    do_add_jours_abonnement args
  end

  # Retourne un Array de toutes les autorisations de
  # l'user qui correspondent à la raison +raison+, qui peut
  # être une expression régulière, comme `/^QUIZ ` pour toutes
  # les autorisations qui viennent des quiz
  def autorisations_for_raison raison
    require_modules_autorisation
    do_autorisations_for_raison raison
  end

  # Retourne un Array de toutes les autorisations
  # de l'user
  def autorisations
    @autorisations ||= table_autorisations.select(where: "user_id = #{id}")
  end

  def table_autorisations
    @table_autorisations ||= site.dbm_table(:hot, 'autorisations')
  end

end
