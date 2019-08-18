# encoding: UTF-8
=begin

  Module qui se charge de la synchronisation des commentaires de
  pages

  Noter que l'opération, contrairement à beaucoup d'autres, ne se
  fait que dans le sens distant -> local.

=end
class Sync

  # = main =
  #
  # Méthode principale appelée par le programme
  # principal.
  #
  def synchronize_page_comments
    @suivi << "* Synchronisation des commentaires de pages"
    @report << "* Synchronisation immédiate des commentaires de pages"
    if Comments.instance.synchronize(self)
      @suivi << "= Synchronisation des commentaires de pages OK"
    else
      @suivi << "# Problème en synchronisation les commentaires de pages"
    end
  end

class Comments
  include Singleton
  include CommonSyncMethods

  attr_reader :nombre_synchronisations

  # Méthode principale qui synchronise les citations entre
  # la table locale et la table distante.
  #
  def synchronize( sync )
    @sync = sync

    @nombre_synchronisations = 0

    # On ne prend que les commentaires datant que de moins de 15 semaines
    drequest = {where: "created_at > #{Time.now.to_i - 15.weeks}"}

    debug "dis_rows : #{dis_rows(drequest).inspect}"

    # Fonctionnement : si le :last_sent d'une citation est différent,
    # c'est la citation distante qui a raison.
    # Dans les autres cas, c'est la citation locale qui a raison.
    dis_rows(drequest).each do |cpid, dis_data|
      suivi "* Traitement de page de commentaire ##{cpid}"
      # Données de la citations locale
      loc_data = loc_rows(drequest)[cpid]

      if loc_data.nil?
        # La donnée locale n'existe pas, on l'enregistre
        # ================== ACTUALISATION ===========================
        loc_table.insert(dis_data)
        @nombre_synchronisations += 1
        report "Commentaire de page ##{cpid} LOCAL créé"
        # ============================================================
      elsif loc_data != dis_data
        # La donnée est différente, il faut actualiser la donnée
        # locale
        dis_data_sans_id = dis_data.dup
        dis_data_sans_id.delete(:id)
        # ================== ACTUALISATION ===========================
        loc_table.update(cpid, dis_data_sans_id)
        @nombre_synchronisations += 1
        report "Commentaire de page ##{cpid} LOCAL actualisé"
        # ============================================================
      else
        # Les deux données sont identiques, il n'y a rien à faire
      end
    end

    unless @nombre_synchronisations == 0
      report "  NOMBRE SYNCRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation des commentaires de pages OPÉRÉE AVEC SUCCÈS'.in_span(class: 'blue bold')
    end
  rescue Exception => e
    debug e
    error "# ERREUR AU COURS DE LA SYNCHRONISATION DES COMMENTAIRES DE PAGES : #{e.message}"
  else
    true
  end

  # Pour les méthodes commune de synchro (module_sync_methods)
  def db_suffix   ; @db_suffix  ||= :cold end
  def table_name  ; @table_name ||= 'page_comments' end

end #/Citations
end #/Sync
