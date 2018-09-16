# encoding: UTF-8
# ---------------------------------------------------------------------
#
#   Class Cron::Processus
#   ---------------------
#   Pour le traitement d'un processus.
#
# ---------------------------------------------------------------------
class Cron
  class Processus

    # Nom du processus
    attr_reader :name

    # La fréquence d'exécution du processus
    # Valeurs possibles :
    #   :each_time
    #   :once_an_hour
    #   :once_a_day
    #   :once_a_week
    attr_reader :frequence

    def initialize proc_name
      @name = proc_name
    end

    # Ne joue le processus que si c'est nécessaire, c'est-à-dire
    # si ça date de dernière exécution correspond à la fréquence
    # donnée.
    #
    # +frequence+   C'est un symbole comme :once_a_day qui
    #               signifie "une fois par jour". Cf. les valeurs
    #               plus haut.
    #
    def run_if_needed frequence
      @frequence = frequence
      REF_LOG_SUIVI.write "   -> Processus<#{name}>#run_if_needed\n"
      if must_be_run?
        run
      else
        REF_LOG_SUIVI.write "       Ce processus ne doit pas être joué\n"
        REF_LOG_SUIVI.write "       Date de dernière exécution  : #{Time.at(last_execution)}\n"
        REF_LOG_SUIVI.write "       Date de prochaine exécution : #{Time.at(time_next_execution)}\n"
      end
    end

    # = main =
    #
    def run
      folder.require
      cron.send("_#{name}".to_sym)
      set_last_execution
    end

    # Retourne true si le processus doit être joué
    def must_be_run?
      frequence.nil? || last_execution.nil? || Time.now.to_i > time_next_execution
    end

    # Retourne la date de dernière exécution
    def last_execution
      @last_execution ||= site.get_last_date(key_last_date)
    end

    # Retourne le temps de prochaine exécution en
    # fonction de la fréquence.
    def time_next_execution
      case frequence
      when :each_time     then last_execution + 10
      when :once_an_hour  then last_execution + 3600 - 10
      when :once_a_day    then last_execution + 1.day  - 10
      when :once_a_week   then last_execution + 7.days - 10
      else raise "La fréquence #{frequence} n'est pas traitée par les processus Cron."
      end
    end

    def set_last_execution
      site.set_last_date(key_last_date)
      @last_execution = nil # pour récupérer sa nouvelle valeur, au cas où
    end

    # La clé pour consigner la date de dernière exécution du processus
    def key_last_date
      @key_last_date ||= "processus_cron_#{name}".to_sym
    end

    def folder
      @folder ||= cron.folder_processus + name
    end

  end #/Processus
end#/Cron
