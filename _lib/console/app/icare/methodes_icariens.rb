# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def set_icarien line
    tout, ref_icarien, action = line.match(/^set icarien (.*?) (inactif|actif|on|off)$/i).to_a
    valeur_bit, new_etat, authorized =
      case action
      when 'actif', 'on'
        ['2', 'actif', true]
      when 'inactif', 'off'
        ['1', 'inactif', false]
      end
    where_clause, de_prop =
      if ref_icarien.numeric?
        [{id: ref_icarien.to_i}, 'd’identifiant']
      else
        [{pseudo: ref_icarien}, 'de pseudo']
      end
    # Il faut toujours faire l'opération sur la table ONLINE
    table_online = site.dbm_table(:hot, 'users', online = true)
    duser = table_online.get(where: where_clause, colonnes: [:options, :pseudo])

    if duser.nil?
      error "L'icarien #{de_prop} `#{ref_icarien}` est introuvable."
    else
      opts = duser[:options]
      opts = opts.split('') # Car il n'y en a peut-être pas 32
      bit31 = opts[31]

      if bit31 == valeur_bit && (authorized == has_autorisation_icarien?(duser))
        error "l'icarien #{duser[:pseudo]} (#{duser[:id]}) est déjà dans l'état #{new_etat} sur le site distant."
      else

        # --- On passe l'icarien dans l'état voulu ---
        # --- On doit modifier ses options ainsi   ---
        # --- que lui ajouter une autorisation     ---

        # Réglage de ses options
        opts[31] = valeur_bit
        opts = opts.collect{|e| e || 0}.join('')
        table_online.update(duser[:id], options: opts)

        # Son enregistrement dans la donnée autorisation
        # Note : doit se faire sur la table online également
        if authorized
          add_autorisation_icarien duser
        else
          remove_autorisation_icarien duser
        end

        flash "Icarien #{duser[:pseudo]} (#{duser[:id]}) a été mis à l'état #{new_etat} sur le site distant."
      end
    end

    return ''
  end

  # Retourne true si l'user a une autorisation icarien
  def has_autorisation_icarien?(duser)
    drequest = {
      where: {user_id: duser[:id], raison: 'ICARIEN ACTIF'}
    }
    table_autorisations_online.count(drequest) > 0
  end

  # Ajoute une autorisation d'icarien actif pour l'icarien
  # qui possède les données +duser+
  def add_autorisation_icarien duser
    count_init = table_autorisations_online.count
    dauto = {
      user_id:        duser[:id],
      raison:         'ICARIEN ACTIF',
      start_time:     Time.now.to_i,
      end_time:       nil,
      nombre_jours:   nil,
      privileges:     nil,
      created_at:     Time.now.to_i,
      updated_at:     Time.now.to_i
    }
    # --- On ajoute l'autorisation ---
    table_autorisations_online.insert(dauto)
    if count_init + 1 == table_autorisations_online.count
      sub_log ""
    else
      sub_log '# IMPOSSIBLE D’AJOUTER L’AUTORISATION DISTANTE… Consulte le debug.'
      debug "DATA USER À AUTORISER : #{duser.inspect}"
      debug "Données autorisation : #{dauto.inspect}"
      debug "Nombre d'autorisations initial : #{count_init}"
    end
  end
  # Retire l'autorisation d'icarien actif pour l'icarien
  # qui possède les données +dusers+
  def remove_autorisation_icarien duser
    drequest = {
      where: "user_id = #{duser[:id]} AND raison = 'ICARIEN ACTIF'"
    }
    count_init = table_autorisations_online.count
    table_autorisations_online.delete(drequest)
    if count_init - 1 == table_autorisations_online.count
      sub_log 'Autorisation retirée avec succès.'
    else
      debug "DONNÉES USER À DÉSAUTORISER : #{duser.inspect}"
      debug "Requête : #{drequest.inspect}"
      debug "Nombre d'autorisations : #{count_init}"
      sub_log 'Impossible de retirer l’autorisation… (consulte le debug pour les données)'
    end
  end
  def table_autorisations_online
    @table_autorisations_online ||= site.dbm_table(:hot, 'autorisations', online = true)
  end

end #/Console
end #/Admin
end #/SiteHtml
