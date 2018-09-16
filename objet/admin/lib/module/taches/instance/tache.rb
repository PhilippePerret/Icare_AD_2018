# encoding: UTF-8
class Admin
class Taches
class Tache

  include MethodesMySQL

  attr_reader :id

  def initialize id = nil
    @id = id
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def tache       ; @tache        ||= get(:tache)       end
  def echeance    ; @echeance     ||= get(:echeance)    end
  def admin_id    ; @admin_id     ||= get(:admin_id)    end
  def state       ; @state        ||= get(:state)       end
  def description ; @description  ||= get(:description) end
  def file        ; @file         ||= get(:file)        end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------
  def admin ; @admin ||= User.get(admin_id) end

  # Retourne :
  #   NIL si la tâche n'a pas d'échéance
  #   0 si l'échéance est aujourd'hui
  #   Le nombre de jours POSITIF si l'échéance est future
  #   Le nombre de jours NÉGATIF si l'échéance est passée
  def nombre_jours_before_echeance
    @nombre_jours_before_echeance ||= begin
      if echeance.nil?
        nil
      else
        ( (echeance - Time.now.to_i) / 1.day ) + 1
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes
  # ---------------------------------------------------------------------
  def create
    @id = table.insert(data2save.merge(created_at:Time.now.to_i))
    param(:todo => nil)
    flash "Tache ##{@id} créée avec succès."
  end
  # Actualisation de la donnée
  def update
    table.update(id, data2save)
    flash "Tache ##{id} actualisée."
  end

  # Arrêter la tâche
  #
  # Cela consiste maintenant à mettre la tâche en archive,
  # i.e. dans la base `site_cold`
  #
  # Noter que l'identifiant en archives reste le même
  # que celui dans la base.
  #
  def stop
    data_cold = {
      # id:           id, NON !!!
      tache:        tache,
      admin_id:     admin_id,
      description:  description,
      file:         file,
      created_at:   created_at,
      state:        9,
      updated_at:   Time.now.to_i
    }
    table_cold.insert(data_cold)
    table.delete(id)
  end

  # Noter que la destruction, si elle doit vraiment être opérationnelle,
  # doit se faire online et offline, sinon la synchronisation remettra
  # toujours la tâche (sauf si elle est enregistrée dans la table cold).
  def destroy
    table.delete( id )
  end
  def data2save
    @data2save ||= {
      tache:        data_param[:tache].nil_if_empty,
      admin_id:     data_param[:admin_id].to_i,
      description:  data_param[:description].nil_if_empty,
      echeance:     echeance_from_param,
      file:         data_param[:file].nil_if_empty,
      state:        1,
      updated_at:   Time.now.to_i
    }
  end
  def echeance_from_param
    peche = data_param[:echeance]
    if peche.numeric?
      peche.to_i # Une ré-édition
    else
      jrs, mois, annee = peche.split(' ')
      Time.new(annee.to_i, mois.to_i, jrs.to_i).to_i
    end
  end
  def data_param
    @data_param ||= param(:todo)
  end

  def table
    @table ||= Admin.table_taches
  end
  def table_cold
    @table_cold ||= Admin.table_taches_cold
  end

  # Return true si les données sont valides
  # Note : La méthode est utilisée par la console à la
  # création de la tâche, pour le moment.
  def data2save_valid?
    d = data2save
    d[:admin_id]  = test_admin_tache( d[:admin_id] || d.delete(:pour) || d.delete(:admin) ) || ( return false )
    d[:tache]     = test_task_tache( d[:tache] || d.delete(:faire) || d.delete(:task)) || (return false)
    d[:echeance]  = test_echeance_tache(d[:echeance] || d.delete(:le))
    return false if d[:echeance] === false
    d[:state]     = test_statut_tache(d[:state] || d.delete(:statut)) || ( return false )
    @data2save = d
  end


  # +aref+ pour "Référence administrateur", soit le pseudo soit l'id
  # de l'administrateur qui doit accomplir la tâche
  # La méthode retourne l'ID de l'administrateur ou génère une
  # error
  def test_admin_tache aref
    if aref.numeric?
      admin_id = aref.to_i
    else
      admin_id = User.table_users.select(where:"pseudo = '#{aref}'", colonnes:[]).first[:id]
      raise "Aucun administrateur ne correspond au pseudo `#{aref}`" if admin_id.nil?
    end
    ua = User.get(admin_id)
    raise "L'user #{ua.pseudo} n'est pas administrateur…" unless ua.admin?
  rescue Exception => e
    debug e
    error e.message
  else
    return admin_id
  end

  # Vérifie la validité de la tache +action+, c'est-à-dire
  # ce qu'il y a vraiment à faire
  def test_task_tache act
    act = act.nil_if_empty
    raise "Il faut définir une action." if act.nil?
    act = act.sub(/^["“']/, '').sub(/["“']$/,'')
  rescue Exception => e
    debug e
    error e.message
  else
    return act
  end

  # Vérifie la validité de l'échéance définie et retourne
  # cette échéance sous forme de nombre de secondes
  # +eche+ Échéance String sous la forme "JJ MM AA" ou alors sous
  # un désignant comme "auj", "dem", "today", "aujourd'hui", etc.
  def test_echeance_tache eche
    return nil if eche.nil_if_empty.nil? || eche == "null"
    eche = Data.date_humaine_to_date_real( eche, "%d %m %Y")
    jour, mois, annee = eche.split(' ').collect{ |e| e.to_i }
    if jour.nil? || mois.nil? || annee.nil?
      raise "L'échéance de la tâche doit être sous la forme JJ MM AA ou être un identifiant comme `dem` pour demain, ou définir `+ nombre_de_jour`, etc. (demander l'aide avec `aide taches`)."
    end
    raise "Le jour de l'échéance doit être inférieur à 31" if jour > 31
    raise "Le mois doit être un nombre entre 1 et 12" if mois > 12 || mois < 1
    annee = 2000 + annee if annee < 100
    t = Time.new(annee, mois, jour)
    return t.to_i
  rescue Exception => e
    return error e.message
  end

  def test_statut_tache st
    return 0 if st.nil?
    raise "Le statut doit être un nombre." unless st.numeric?
    st = st.to_i
    raise "Le statut doit être supérieur à 0" if st < 0
    raise "Le statut ne doit pas être 9 — fini — à la création…" if st == 9
    raise "Le statut doit être inférieur à 9" if st > 8
  rescue Exception => e
    debug e
    return error e.message
  else
    return st
  end

end #/Tache
end #/Taches
end #/Admin
