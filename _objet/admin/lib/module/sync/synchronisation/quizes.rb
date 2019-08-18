# encoding: UTF-8
=begin

  Module pour synchroniser tous les quizes

=end
class Sync
  def synchronize_quizes
    @report << "* Synchronisation de TOUS LES QUIZ"
    if Sync::Quizes.instance.synchronize(self)
      @suivi << "= Synchronisation de TOUS LES QUIZ OPÉRÉE AVEC SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation de TOUS LES QUIZ".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end

  class Quizes
    include Singleton
    include CommonSyncMethods

    # = main =
    #
    # Méthode principale de synchronisation de tous les quiz.
    #
    def synchronize sync
      @sync = sync
      @nombre_synchronisations = 0
      site.require_objet 'quiz'
      ::Quiz.all_suffixes_quiz.each do |sufbase|
        synchronize_base sufbase
      end
      if @nombre_synchronisations > 0
        report "  NOMBRE DE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
        report '  = Synchronisation de TOUS LES QUIZ OPÉRÉE AVEC SUCCÈS'
      end
    rescue Exception => e
      error e.message
      false
    else
      true
    end


    def synchronize_base suf
      @db_suffix = "quiz_#{suf}"
      suivi "* Synchronisation de la base de quiz `#{@db_suffix}'"
      ['quiz', 'questions'].each do |tb_name|
        self.table_name= tb_name
        suivi "Contrôle de la table `#{table_name}' de la base `#{db_suffix}'"
        nom_chose = {
          'quiz'      => "Questionnaire",
          'questions' => "Question"
        }[tb_name]
        # On vérifie que toutes les données locales soient
        # conformes aux données distantes
        loc_rows.each do |rid, loc_data|
          dis_data = dis_rows[rid]
          if dis_data.nil?
            # La données distante n'existe pas
            dis_table.insert( loc_data )
            report "#{nom_chose} ##{rid} ajouté ONLINE"
            @nombre_synchronisations += 1
            suivi "Le #{nom_chose} ##{rid} n'existe pas sur la base distante"
          elsif dis_data[:updated_at] > loc_data[:updated_at]
            # La donnée distante est plus récente, elle doit être
            # actualisée en local
            dis_data_sans_id = dis_data.dup
            dis_data_sans_id.delete(:id)
            loc_table.update(rid, dis_data_sans_id)
            report "#{nom_chose} ##{rid} actualisé en local"
            @nombre_synchronisations += 1
            suivi "Le #{nom_chose} ##{rid} distant est plus récent => update local requis"
          elsif dis_data[:updated_at] < loc_data[:updated_at]
            # La donnée locale est plus récente, elle doit être actualisée
            # en distant
            loc_data_sans_id = loc_data.dup
            loc_data_sans_id.delete(:id)
            dis_table.update(rid, loc_data_sans_id)
            report "#{nom_chose} ##{rid} actualisé sur la base distante"
            @nombre_synchronisations += 1
            suivi "Le #{nom_chose} ##{rid} local est plus récent => update distant requis"
          else
            suivi "Le #{nom_chose} ##{rid} est correct."
          end
        end

        # Par rapport au quiz distant, il ne faut rien traiter pour
        # le moment puisqu'on ne peut pas ajouter de quiz distant
        # dis_rows.each do |rid, dis_data|
        #   loc_data = loc_rows[rid]
        #
        # end
      end
      suivi "  = OK"
    end
  end #/Quizes
end #/Sync
