# encoding: UTF-8
class Database
class Table
class << self

  # = main =
  #
  # Méthode principale pour procéder à la synchronisation des tables
  # online et offline.
  #
  def _synchronize
    if param(:confirmed).nil?
      message_confirmation
    else
      proceed_synchronisation
    end
  rescue Exception => e
    debug e
    "ERREUR DANS LA SYNCHRONISATION : #{e.message} (détail dans le fichier debug)"
  end

  def message_confirmation
    m = String.new
    m << "Synchronisation de la table <strong>#{table_designation}</strong> #{sens_humain}."
    params[:where].nil? || begin
      m << "\nLes rangées à synchroniser doivent répondre au filtre : <span class='red'>#{params[:where].inspect}</span>. "
    end
    params[:columns].nil? || begin
      m << "Seules les colonnes <span class='red'>#{params[:columns].inspect}</span> seront affectées (les autres garderont leur valeur)"
    end
    m << 'Confirmer la synchronisation'.in_a(onclick: "$.proxy(Database,'confirm_synchronisation')()", class: 'btn').in_div(class: 'air right')
  end

  def params
    @params ||= begin
      w = param(:filter).nil_if_empty
      w.nil? || begin
        w = w.start_with?('{') ? eval(w) : w
      end
      c = param(:columns).nil_if_empty
      c.nil? || begin
        c = c.split(',').collect{|e| e.strip.to_sym}
      end
      {
        base:       param(:dbname),
        table:      param(:tblname),
        sens:       param(:sens_synchro), # d2l ou l2d
        where:      w,
        columns:    c,
        pure_mysql: param(:pure_mysql) == 'on'
      }
    end
  end

  def sens_humain
    @sens_humain ||= begin
      from = params[:sens] == 'd2l' ? 'distant' : 'local'
      vers = params[:sens] == 'd2l' ? 'local'   : 'distant'
      "du <b>site #{from} vers le site #{vers}</b>. Toutes les données #{vers}es plus anciennes que les données #{from}es seront remplacées. Les données <b>#{from}es</b> ne seront pas affectées"
    end
  end

  def table_designation
    @table_designation ||= "#{site.prefix_databases}_#{params[:base]}.#{params[:table]}"
  end



  # ---------------------------------------------------------------------
  #
  #     SYNCRHONISATION
  #
  # ---------------------------------------------------------------------

  # = main =
  #
  # Méthode principale qui procède vraiment à la synchronisation
  #
  def proceed_synchronisation
    resultat = Array.new
    suivi_complet = Array.new
    resultat << "=== SYNCHRONISATION #{Time.now} ==="
    resultat << "=== BASE  : #{params[:base]}"
    resultat << "=== TABLE : #{params[:table]}"
    resultat << "=== SENS  : #{params[:sens] == 'd2l' ? 'distante vers locale' : 'locale vers distante'}"
    resultat << ""
    table_online  = site.dbm_table(params[:base], params[:table], online = true)
    table_offline = site.dbm_table(params[:base], params[:table], online = false)

    table_src, table_des =
      if params[:sens] == 'd2l'
        [table_online, table_offline]
      else
        [table_offline, table_online]
      end

    # Pour construire la requête finale
    drequest = Hash.new

    # Récupérer les rangées en fonction des filtres éventuels
    if params[:where]
      drequest.merge!(where: params[:where])
    end
    if params[:columns]
      drequest.merge!(colonnes: params[:columns])
    end

    resultat << "drequest : #{drequest.inspect}"



    rows_src = table_src.select(drequest)

    # Les colonnes pour chaque rangée synchronisée
    des_colonnes =
      if params[:columns].nil?
        ""
      else
        " des colonnes #{params[:columns].collect{|c| ":#{c}"}.pretty_join}"
      end

    resultat << "\n"+ "-"*80+"\n"


    # === On procède à la synchronisation
    rows_src.each do |row_src|
      begin
        row_id = row_src[:id]

        # On prend la rangée de destination pour la comparer à la
        # rangée source. Pour
        # Pour le moment, la rangée est à actualiser si la propriété
        # updated_at est inférieure. On signale aussi lorsque les propriétés
        # update_at sont différentes.
        row_des = table_des.get(row_id)

        unknown_distant_data = row_des == nil

        unless unknown_distant_data
          if row_des[:updated_at] < row_src[:updated_at]
            resultat << "\n\n* Sync#{des_colonnes} de la rangée ##{row_id}"
          else
            suivi_complet << "= Rangée ##{row_id} synchronisée"
            next
          end

          # On regarde les données à actualiser (pour ne pas tout actualiser)
          data2update = Hash.new
          row_src.each do |k, v|
            v.instance_of?(String) && v = v.force_encoding('utf-8')
            data2update.merge!(k => v) if row_des[k] != v
          end
        end

        div_detail_id = "div_detail_#{row_id}"
        lien_detail = 'détail'.in_a(onclick: "$('div##{div_detail_id}').toggle()")
        balise_in = " (#{lien_detail})<div id='#{div_detail_id}' style='display:none'>"

        if unknown_distant_data
          # Création de la rangée
          # ---------------------
          table_des.insert(row_src)
          resultat << "  = CREATION de la rangée de destination#{balise_in}#{row_src.inspect}</div>"
        elsif params[:columns].nil?
          # Modification des données divergentes
          # ------------------------------------
          table_des.update(row_id, data2update)
          resultat << "  = UPDATER les données des colonnes #{data2update.keys.collect{|k| ":#{k}"}.pretty_join}#{balise_in}#{data2update.inspect}</div>"
        else
          # Modification des colonnes voulues
          # ---------------------------------
          data2update = Hash.new
          params[:columns].each do |column|
            row_des[column] != row_src[column] || next
            data2update.merge!(column => row_src[column])
          end
          table_des.update(row_id, new_data)
          resultat << "  = UPDATER Les colonnes #{data2update.keys.collect{|k| ":#{k}"}.pretty_join}#{balise_in}#{data2update.inspect}</div>"
        end
      rescue Exception => e
        mess = "Problème avec la rangée d'ID #{row_id} : #{e.message}"
        resultat << "### #{mess}"
        debug mess
        debug e
      end
    end
    # /fin de boucle sur chaque rangée
    resultat << "\n"+ "-"*80+"\n"

    resultat.join("\n") +
    'Suivi complet'.in_h3 +
    suivi_complet.join("\n")
  end
end #/<< self
end #/Table
end #/Database
