# encoding: UTF-8
class Sync
  def synchronize_forum
    @report << "* Synchronisation du FORUM"
    if Sync::Forum.instance.synchronize(self)
      @suivi << "= Synchronisation du FORUM opérée avec SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation du FORUM".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Forum
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    # On doit synchroniser toutes les tables distantes
    # vers locales.
    #
    # NOTES : on ne doit JAMAIS toucher les tables
    # distantes par ce biais.
    [
      'posts', 'posts_content', 'sujets',
      'follows', 'posts_votes'
    ].each do |table_name|
      report "  * Traitement table #{table_name}"
      @table_name = table_name
      reset # pour prendre en compte
      loc_table.delete
      dis_rows.each do |rid, dis_data|
        loc_table.insert(dis_data)
        report "    - Rangée ##{rid}"
        @nombre_synchronisations += 1
      end
    end
    if @nombre_synchronisations > 0
      report "  = NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation du FORUM opérée avec SUCCÈS'.in_span(class:'blue bold')
    end
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  def db_suffix
    @db_suffix ||= :forum
  end
end #/Filmodico
end #/Sync
