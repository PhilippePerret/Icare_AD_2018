# encoding: UTF-8
# raise_unless_admin
class Admin
class Taches
class << self

  # Test de la synchronisation online/offline
  def test_synchro
    OFFLINE || return
    dis_table = site.dbm_table(:hot, 'taches', online = true)
    loc_table = site.dbm_table(:hot, 'taches', online = false)
    dis_rows = dis_table.select
    loc_rows = loc_table.select
    # debug "ROWS DISTANTES : #{dis_rows.inspect}"
    # debug "ROWS LOCALES : #{loc_rows.inspect}"
    if dis_rows == loc_rows
      # flash "Les deux tables loc/dis sont synchronisées."
    else
      # = TABLES LOCALE/DISTANTE DÉSYNCHRONISÉES =
      dis_rows.each do |dis_row|
        loc_row = loc_rows[dis_row[:id]]
        if loc_row.nil?
          # CRÉATION EN LOCAL
          loc_table.insert(dis_row)
          debug "Création locale de #{dis_row.inspect}"
        elsif loc_row != dis_row
          # UPDATE EN LOCAL
          loc_table.update(dis_row.delete(:id), dis_row)
          debug "UPDATE locale de #{dis_row.inspect}"
        else
          # OK
        end
      end
      loc_rows.each do |loc_row|
        dis_row = dis_rows[loc_row[:id]]
        if dis_row.nil?
          # CRÉATION EN DISTANT
          dis_table.insert(loc_row)
          debug "Création distante de #{loc_row.inspect}"
        end
      end
      flash "Les tables online et offline ont été synchronisées."
    end
  end

  # Création de la tache
  def create
    data_valid? || return
    debug "Tache : #{dparam.pretty_inspect}"
    tid = table.insert(dparam)
    flash "Tache ##{tid} créée avec succès."
    param(tache: nil)
  end

  def data_valid?
    user.admin? || raise('Seul un administrateur peut créer une tache par ce biais.')
    dparam[:admin_id] = user.id
    dparam[:tache] = dparam[:tache].nil_if_empty
    dparam[:tache] != nil || raise('Il faut définir la tache.')
    # Traitement de l'échéance
    eche = dparam[:echeance].nil_if_empty
    eche != nil || raise('Il faut toujours définir une échéance pour les tâches Icare.')
    eche =
      case true
      when eche == 'auj'  then NOW
      when eche == 'dem'  then NOW + 1.day
      when eche.start_with?('+')
        NOW + eche[1..-1].to_i.days
      when eche.start_with?('-')
        NOW - eche[1..-1].to_i.days
      when eche =~ /^([0-9]{0,2})\/([0-9]{0,2})\/20([0-9]{2,2})/
        jr, ms, an = eche.scan(/^([0-9]{0,2})\/([0-9]{0,2})\/20([0-9]{2,2})/).to_a.first.collect{|i|i.to_i}
        Time.new(2000+an, ms, jr).to_i
      else
        raise 'Le format d’échéance est inconnu.'
      end
    dparam[:echeance] = eche
    dparam[:created_at] = Time.now.to_i
    dparam[:updated_at] = Time.now.to_i
  rescue Exception => e
    @error_when_create = true # pour laisser le formulaire ouvert
    debug e
    error e.message
  else
    true
  end

  def dparam
    @dparam ||= param(:tache)
  end


  def table
    @table ||= Admin.table_taches
  end

end # << self
end #/Taches
end #/Admin
