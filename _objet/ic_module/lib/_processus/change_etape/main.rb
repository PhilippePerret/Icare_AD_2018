# encoding: UTF-8
=begin

  Ce module permet de procéder au changement d'étape après que Phil
  aie choisi l'étape.

  Note :

    ATTENTION : si ce module est changé, les changements doivent être
    reportés dans le fichier
    ./objet/admin/lib/module/operations_user/etape_change.rb qui permet
    de forcer un changement d'étape.

=end

# L'icetape précédente doit être enregistré dans la donnée
# icetapes de l'icmodule
begin
  site.require_objet 'ic_etape'

  etapes = (icmodule.icetapes || "").split(' ')
  etapes << icetape.id
  etapes = etapes.join(' ')

  # L'étape précédente doit-elle compter comme une vraie étape ?
  # Noter qu'il s'agit de l'étape courante de l'icarien, pas l'étape
  # qu'on va mettre en étape courante.
  if param(:prev_etape_is_real) == 'on'
    icetape.set(options: icetape.options.set_bit(1,1))
  end

  new_icetape = IcModule::IcEtape.create_for(icmodule, next_abs_etape.numero)

  icmodule.set(
    icetapes:     etapes,
    icetape_id:   new_icetape.id
  )

  # Un watcher pour rendre le travail de cette étape
  owner.add_watcher(
    objet:      'ic_etape',
    objet_id:   new_icetape.id,
    processus:  'send_work'
  )

  
  # On détruit le fichier statistiques, car le nombre d'étapes
  # a forcément changé.
  Atelier.remove_statistiques_file


  begin
    # Actualité
    # ---------
    site.require_objet 'actualite'
    SiteHtml::Actualite.create(
      user_id: owner.id,
      status:  2,
      message: "<strong>#{owner.pseudo}</strong> passe à l'étape #{next_abs_etape.numero}"+
        " de son module d’apprentissage “#{absmodule.name}”. Bon courage à #{owner.femme? ? 'elle' : 'lui'} !"
    )
  rescue Exception => e
    debug e
  end


  flash "Changement d'étape opéré pour #{owner.pseudo} (#{owner.id})" +
     "<br>---------------------------------------------------------" +
    "<br>Ancienne : #{absetape.numero} : #{absetape.titre}" +
    "<br>Nouvelle : #{new_icetape.abs_etape.numero} : #{new_icetape.abs_etape.titre}"

rescue Exception => e
  debug e
  dont_remove_watcher
  no_mail_user
  error "Une erreur est survenue : #{e.message}."
end
