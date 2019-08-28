# encoding: UTF-8
=begin

  Extension de la classe Admin pour le tableau de bord de l'administrateur

=end
raise_unless_admin
class Dashboard
class << self
  attr_accessor :content
end# << self
end#/Dashboard

case param(:opadmin)
when 'check_synchro'
  begin
    # Procède au check de la synchro des sites local/distant
    f = (site.folder_deeper + 'module/synchronisation/synchronisation.rb')
    f.require
  rescue Exception => e
    debug e
    error e.message
  else
    flash "Check de synchro exécutée avec succès."
  ensure
    redirect_to :last_page
  end
when 'check_all_deserbage_travaux'
  # Méthode permettant de tester toutes les étapes de
  # travaux ainsi que tous les travaux types
  dreq = {colonnes: [:travail]}
  erreurs = Array.new
  success = Array.new
  codes   = Array.new
  REG_ERB = /<%(.*?)%>/o
  dbtable_absetapes.select(dreq).each do |hetape|
    begin
      codes << hetape[:travail].scan(REG_ERB).to_a.collect{|h| h[0]}.join('<br>')
      ERB.new(hetape[:travail]).result()
      success << "ABS ETAPE ID #{hetape[:id]}".in_div
    rescue Exception => e
      erreurs << "ABS ETAPE ID #{hetape[:id]} : #{e.message}".in_div
    end
  end
  dbtable_travaux_types.select(dreq).each do |hwt|
    begin
      codes << hwt[:travail].scan(REG_ERB).to_a.collect{|h| h[0]}.join('<br>')
      ERB.new(hwt[:travail]).result
      success << "TRAVAIL TYPE ID #{hwt[:id]}".in_div
    rescue Exception => e
      erreurs << "TRAVAIL TYPE ID #{hwt[:id]} : #{e.message}".in_div
    end
  end

  Dashboard.content= '=== CODES ==='.in_h3 +
    codes.join +
    '=== ERREURS ==='.in_h3(class: 'red') +
    erreurs.join +
    '=== SUCCÈS ==='.in_h3 +
    success.join

when 'erase_user_test'
  # Procédure permettant de détruire un user partout (pour essai
  # avec Marion)
  USER_KILLED_ID = 84

  # Il faudrait aussi détruire les documents du quai
  # des docs
  site.require_objet 'ic_document'
  site.require_objet 'quai_des_docs'
  dbtable_icdocuments.select(where:{user_id: USER_KILLED_ID}, colonnes: []).each do |hdoc|
    icdoc = IcModule::IcEtape::IcDocument.new(hdoc[:id])
    [:original, :comments].each do |typ|
      if icdoc.exist?(typ)
        icdoc.qdd_path(typ).remove
        debug "- Document #{icdoc.qdd_path(typ)} détruit"
      end
    end
  end

  req = {where: {user_id: USER_KILLED_ID}}
  dbtable_actualites.delete(req)
  dbtable_watchers.delete(req)
  dbtable_icdocuments.delete(req)
  dbtable_icetapes.delete(req)
  dbtable_icmodules.delete(req)
  dbtable_paiements.delete(req)

  reqid = {where: {id: USER_KILLED_ID}}
  [
    [:hot, 'connexions'],
    [:users, 'users'],
    [:modules, 'mini_faq']
  ].each do |base, table|
    site.dbm_table(base, table).delete(reqid)
  end

  # On met le prochain id à la valeur juste supérieure au dernier
  [
    dbtable_users,
    dbtable_icdocuments,
    dbtable_watchers
  ].each { |tbl| tbl.reset_next_id }

  flash "J'ai détruit l'user ##{USER_KILLED_ID} partout"
end
