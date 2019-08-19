# encoding: UTF-8
=begin

  Module contenant des méthodes ponctuelles pour gérer les
  autorisations des utilisateurs.

  Rappel : c'est maintenant dans la table 'autorisations' de la
  base `cold` qui sont enregistrées les autorisations des users.

  NOTES IMPORTANTES

    * Voir les méthodes propres à l'application dans le dossier
      ./_lib/modules_optional/User_autorisations/
    * Un même utilisateur peut avoir plusieurs rangées d'autorisation,
      ceci afin de toujours savoir d'où provient l'autorisation.
      Par exemple, si elle vient d'un quiz en particulier, l'autorisation
      a pour raison "QUIZ <suffixe base> <quiz id>" et permet d'empêcher
      l'user de recommencer la même chose avec le même questionnaire.
    * Voir aussi le module `autorisations.rb` dans les requis user qui
      contient les méthodes de base, utiles tout le temps.

=end
class User

  # Appeler User#add_jours_abonnement
  def do_add_jours_abonnement args
    # pour la clarté, je ne merge pas dans +args+

    # Si :start_time et :nombre_jours sont définis, et que l'user
    # possède déjà une autorisation en cours, il faut ajouter
    # la nouvelle autorisation "au bout" de la dernière de l'user
    if args[:start_time] && args[:nombre_jours]
      last_end_time = self.authorized_upto
      last_end_time.nil? && args[:start_time] = last_end_time
    end

    # Définir le temps de fin
    args[:end_time] ||= begin
      stime   = args[:start_time]
      nbjours = args[:nombre_jours]
      if stime && nbjours
        args.merge!( end_time: stime + nbjours.days )
      end
    end

    add_autorisation(
      type:         :autre_raison,
      raison:       args[:raison],
      nombre_jours: args[:nombre_jours],
      start_time:   args[:start_time],
      privileges:   args[:privileges],
      end_time:     args[:end_time]
    )
  end

  # Appeler User#autorisations_for_raison
  def do_autorisations_for_raison raison
    goods = Array.new
    autorisations.each do |row|
      good_raison =
        case raison
        when String   then row[:raison] == raison
        when Regexp   then row[:raison] =~ raison
        when NilClass then row[:raison] == nil # sans raison
        else raise 'La raison est d’un format inconnu…'
        end
      goods << row if good_raison
    end
    return goods
  end
end
