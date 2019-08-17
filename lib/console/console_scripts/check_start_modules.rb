# encoding: UTF-8
=begin

  Module pour checker les débuts et fins de modules (et options) pour
  corriger les erreurs éventuelles.

  Pour jouer le module, copier-coller la ligne de code suivante
  dans le fichier ./objet/site/home.rb

      require './lib/console/console_scripts/check_start_modules.rb'
      
=end
site.require_objet 'ic_module'
site.require_objet 'ic_etape'

table_modules_online = site.dbm_table(:modules, 'icmodules', online = true)
request = {
  colonnes: []
}
dbtable_icmodules.select(request).each do |hmod|
  new_dmodule = Hash.new
  icmodule = IcModule.new(hmod[:id])
  debug "\n\nMODULE ##{icmodule.id} : #{icmodule.abs_module.name} de #{icmodule.owner.pseudo}"

  if icmodule.started_at.nil?
    debug "# PAS DE STARTED AT…"
    new_dmodule.merge!(started_at: icmodule.created_at)
  else
    debug "Started at : #{icmodule.started_at.as_human_date(true, true)}"
  end
  if icmodule.created_at.nil?
    debug "# PAS DE CREATED_AT…"
  else
    debug "Created at : #{icmodule.created_at.as_human_date(true, true)}"
  end


  etapes_ids = icmodule.icetapes
  etapes_ids != nil || next
  debug "ICETAPES (propriété) : #{etapes_ids}"
  etapes_ids = etapes_ids.split(' ').collect{|e| e.to_i}

  # Étapes mais dans la table
  erequest = {
    where: {icmodule_id: icmodule.id},
    order: 'started_at ASC',
    colonnes: [:started_at]
  }
  etapes_ids_tbl = dbtable_icetapes.select(erequest).collect{|h|h[:id]}
  debug "ICETAPES (dans table icetapes) : #{etapes_ids_tbl.join(' ')}"

  first_etape_id = etapes_ids.first
  first_etape_id_tbl = etapes_ids_tbl.first

  if first_etape_id == first_etape_id_tbl
    debug "Première étape correspond (propriété/table)"
  else
    debug "# PREMIÈRE ÉTAPE DE CORRESPOND PAS"
  end

  first_etape = IcModule::IcEtape.new first_etape_id

  if icmodule.started_at.nil?
    new_dmodule.merge!(first_etape.started_at)
  else
    if icmodule.started_at > first_etape.started_at
      debug "# STARTED_AT première étape ne correspond pas"
      debug "# => Il faut mettre le démarrage du module à #{first_etape.started_at.as_human_date}"
      error "Module ##{icmodule.id} erroné"
      new_dmodule.merge!(
        created_at: first_etape.started_at,
        started_at: first_etape.started_at
      )
    else
      debug "- started_at du module OK par rapport à première étape"
    end
  end

  # Synchroniser la date de création avec la date de
  # démarrage si nécessaire
  if icmodule.created_at.nil?
    new_dmodule.merge!(created_at: new_dmodule[:started_at])
  end

  # ENDED_AT
  if icmodule.ended_at.nil? && icmodule.icetape_id.nil?
    debug "# ENDED_AT n'est pas défini alors qu'il n'y a plus d'étape"
    last_etape = IcModule::IcEtape.new(etapes_ids_tbl.last)
    fin_etape = last_etape.ended_at
    if fin_etape.to_i == 0
      fin_etape = last_etape.started_at + 9.days
    end
    debug "# Utilisation de la fin de la dernière étape : #{fin_etape.as_human_date}"
    new_dmodule.merge!(ended_at: fin_etape)
  end

  # OPTIONS
  debug "Options    : #{icmodule.options}"
  if icmodule.ended_at != nil && icmodule.options[0].to_i < 3
    new_dmodule.merge!( options: icmodule.options.set_bit(0, 3) )
  end

  new_dmodule.empty? || begin
    debug "ACTUALISATION DES DONNÉES DU MODULE ##{icmodule.id} ONLINE ET OFFLINE AVEC :"
    debug new_dmodule.inspect
    table_modules_online.update(icmodule.id, new_dmodule)
    dbtable_icmodules.update(icmodule.id, new_dmodule)
  end
  # break
end
