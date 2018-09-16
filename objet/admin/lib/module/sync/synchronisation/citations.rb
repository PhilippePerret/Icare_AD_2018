# encoding: UTF-8
=begin

  Module de synchronisation des citations.

  Cette synchronisation consiste à :

  - Modifier en local les propriétés :last_sent
  - Ajouter en distant les nouvelles citations
  - Modifier en distant les citations modifiées

=end
class Sync

  # = main =
  #
  # Méthode principale appelée par le programme
  # principal.
  #
  # Noter que cette synchronisation est presque identique
  # à celle des tweets permanents et qu'on pourrait donc
  # être plus DRY en rationalisant les choses.
  #
  def synchronize_citations
    @suivi << "* Synchronisation des citations"
    @report << "* Synchronisation immédiate des citations"
    if Citations.instance.synchronize(self)
      @suivi << "= Synchronisation des citations OK"
    else
      @suivi << "# Problème en synchronisation les citations"
    end
  end

class Citations
  include Singleton
  include CommonSyncMethods

  attr_reader :nombre_synchronisations

  # Méthode principale qui synchronise les citations entre
  # la table locale et la table distante.
  #
  def synchronize( sync )
    @sync = sync

    suivi "Relève des citations distantes"
    dis_citations = dis_rows
    report "Nombre de citations distantes : #{dis_citations.count}"
    suivi "Relève des citations locales"
    loc_citations = loc_rows
    report "Nombre de citations locales   : #{loc_citations.count}"

    @nombre_synchronisations = 0

    # On conserve les ID des citations distantes pour savoir
    # s'il y a eu des ajouts
    cids_dis = []

    # Fonctionnement : si le :last_sent d'une citation est différent,
    # c'est la citation distante qui a raison.
    # Dans les autres cas, c'est la citation locale qui a raison.
    dis_citations.each do |cid, dis_citation|
      cids_dis << cid
      suivi "* Traitement de citation ##{cid}"
      # Données de la citations locale
      loc_citation = loc_citations[cid]

      if loc_citation[:last_sent] != dis_citation[:last_sent]
        # ================== ACTUALISATION ===========================
        loc_table.update(cid, { last_sent: dis_citation[:last_sent] })
        @nombre_synchronisations += 1
        # ============================================================
        report "Citation ##{cid} LOCALE : :last_sent modifié (#{loc_citation[:last_sent].inspect} -> #{dis_citation[:last_sent].inspect})"
        # Note : Il faut aussi modifier :last_sent dans la donnée
        # loc_citation courante, car si on a modifié quelque chose
        # d'autre (par exemple la description), elle devra être
        # corrigée ci-dessous
        loc_citation[:last_sent] = dis_citation[:last_sent]
      end

      # Si les deux citations n'ont pas les mêmes données, il
      # faut les actualiser
      if loc_citation != dis_citation
        loc_citation.each do |k, v|
          if v != dis_citation[k]
            suivi "    Propriété :#{k} différente."
          end
        end
        # ======= ACTUALISATION ============
        dis_table.update(cid, loc_citation)
        @nombre_synchronisations += 1
        # ==================================
        report "Citation ##{cid} DISTANTE actualisée."
      end
    end

    # Ajoute sur la base distante des nouvelles citations
    # ajoutées en locale
    loc_citations.each do |cid, loc_data|
      next if dis_citations.key?(cid)
      # ======= ACTUALISATION ============
      dis_table.insert(loc_data)
      @nombre_synchronisations += 1
      # ==================================
      report "  = Ajout de la citation DISTANTE ##{cid}"
    end

    unless @nombre_synchronisations == 0
      report "  NOMBRE SYNCRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation des citations OPÉRÉE AVEC SUCCÈS'.in_span(class: 'blue bold')
    end
  rescue Exception => e
    debug e
    error "# ERREUR AU COURS DE LA SYNCHRONISATION DES CITATIONS : #{e.message}"
  else
    true
  end

  # Pour les méthodes commune de synchro (module_sync_methods)
  def db_suffix   ; @db_suffix ||= :cold end
  def table_name  ; @table_name ||= 'citations' end

end #/Citations
end #/Sync
