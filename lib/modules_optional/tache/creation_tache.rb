# encoding: UTF-8
=begin

Ce module permet d'insérer dans la page, lorsque l'on est administrateur,
un bouton permettant de générer automatiquement une tâche pour corriger,
relire, signaler un bug, etc.

=end
class ::Admin
class Taches
  class << self

    # = main =
    #
    # Méthode appelée par Ajax par le widget pour
    # créer une nouvelle tâche
    #
    # Toutes les informations transmises se trouvent dans
    # le paramètre `tache'.
    #
    def create_tache_from_widget
      new_tache = NewTache.new(param(:tache))
      res = new_tache.create
      if res.nil?
        Ajax << { message: new_tache.message_confirmation }
      else
        Ajax << { error: res }
      end
    end

  end #/ << self ::Admin::Taches

  # ---------------------------------------------------------------------
  #   Instance d'une tache ajoutée
  # ---------------------------------------------------------------------
  class NewTache

    # ID absolu de la tâche (dans DATA_TACHES_TYPE)
    attr_reader :id_abs

    # {String} Détail (if any) de la tâche
    attr_reader :detail

    # {Integer} Nombre de jours pour l'échéance
    # Cf. la méthode `echeance_time`, qui retourne l'échéance exacte
    attr_reader :echeance

    # {String} La route de la page
    attr_reader :route

    # {Integer} Importance de la tâche
    attr_reader :importance

    # {String} La "last-route" de la page, donc la route
    # appelée avant de l'atteindre
    attr_reader :last_route

    # {String} Titre de la page
    attr_reader :titre_page

    # {String} Le querystring de l'url
    attr_reader :query_string

    # {Array of Integer} Liste des IDs de tâches créées
    # (correspond au nombre de destinataires)
    attr_reader :taches_ids

    def initialize datainst
      # debug "DATA reçues pour initialiser la tâche : #{datainst.inspect}"
      @id_abs       = datainst[:id].to_sym
      @detail       = datainst[:detail].nil_if_empty
      @route        = datainst[:current_route]
      @last_route   = datainst[:last_route].nil_if_empty
      @qs_init      = datainst[:query_string].nil_if_empty
      @titre_page   = datainst[:titre_page].strip_tags.nil_if_empty
      @importance   = datainst[:importance].to_i
      @echeance     = datainst[:echeance].to_i
    end

    # Créer la tâche
    def create
      data_tache = {
        tache:        content,
        admin_id:     nil,
        description:  detail, # ajouté parfois au message aussi
        echeance:     echeance_time,
        state:        importance,
        created_at:   Time.now.to_i,
        updated_at:   Time.now.to_i
      }

      # Une instance de la table contenant toutes les taches
      tbl = site.dbm_table(:hot, 'taches')

      # On crée la tâche pour chaque destinataire
      @taches_ids = Array.new
      destinataires.each do |u|
        @taches_ids << tbl.insert(data_tache.merge(admin_id: u.id))
      end

    rescue Exception => e
      debug e
      e.message
    else
      nil # pas d'erreur
    end

    def message_confirmation
      "Tâche créée avec succès pour #{destinataires.collect{|u|u.pseudo}.pretty_join}."
    end

    # ---------------------------------------------------------------------
    #   Les données de la tâche à enregistrer
    # ---------------------------------------------------------------------

    # {String} Compose le contenu de la page
    def content
      c = word_place # Par exemple "ANALYSE"
      c += template % {page: link_to_page, detail: detail}
      # Si celui qui dépose la tâche n'est pas le même que
      # celui qui doit la recevoir.
      if user.id != destinataires.first.id
        c += " (tâche déposée par #{user.pseudo} ##{user.id})"
      end

      return c
    end

    # {Integer} Échéance pour la tâche, en fonction de son
    # type ou de la valeur spécifiée dans le menu échéance
    def echeance_time
      @echeance_time ||= begin
        Time.now.to_i + echeance.days
      end
    end

    def template
      @template ||= data_absolues[:template]
    end

    # Un lien vers la page (à ajouter dans le texte
    # de la tâche)
    def link_to_page
      r = route
      if query_string != nil
        r, rien = route.split('?') if route.match(/\?/)
        r += "?#{query_string}"
      end
      @link_to_page = (titre_page || "cette page").in_a(href:r, target:'_blank')
    end

    #  / fin des données enregistrées
    # ---------------------------------------------------------------------

    # {String} LIEU principal de la tâche, par exemple les
    # analyses ou la collection Narration, pour indiquer dans le
    # premier mot du message où se fait la tâche
    def word_place
      @word_place ||= begin
        case true
        when narration?   then "NARRATION "
        when analyse?     then "ANALYSES "
        when unan?        then "UNAN "
        else
          case objet
          when "analyse"    then "ANALYSES "
          when "narration"  then ""
          else
            ""
          end
        end
      end
    end

    def narration?
      objet == "narration" || query_string.match(/\bin=cnarration\b/)
    end
    def analyse?
      objet == "analyse" || query_string.match(/\bin=analyse\b/)
    end
    def unan?
      objet == "unan" || query_string.match(/\bin=unan\b/)
    end

    def objet
      @objet ||= route.split('/').first
    end
    # {Array} LISTE des instances user des destinataires
    # de la tâche. Il n'y en a souvent qu'un seul, mais
    # on ne sait jamais.
    def destinataires
      @destinataires ||= begin
        case data_absolues[:dest]
        when :manitou
          # TODO: Plus tard, il faudra pouvoir récupérer une
          # liste d'administrateur qualifiés, pour le moment
          # je ne mets que moi
          [User::get(1)]
        when :lecteurs
          # TODO: Pour le moment, il n'y a que Marion, plus
          # tard, il faudra faire une distinction en fonction
          # de la page sur laquelle on se trouve (sur la page
          # des analyses, ce sera les lecteurs des analyses,
          # etc.)
          [User::get(3)]
        else
          # C'est l'user qui crée la tâche, mais on passe
          # plutôt par cette formule car il est aussi possible
          # de stipuler explicitement un ID de user (moi par
          # exemple)
          [ User::get(data_absolues[:dest]) ]
        end
      end
    end


    # La donnée +query_string+ contient les données
    # _o, _i etc.
    def query_string
      @query_string ||= begin
        qs = (@qs_init || '').as_hash_from_query_string
        # On retire les valeurs inutiles
        [:__o, :__i, :__m].each { |k| qs.delete k }
        qs.collect{|k,v| "#{k}=#{v}"}.join('&').nil_if_empty || ''
      end
    end

    def data_absolues
      @data_absolues ||= DATA_TACHES_TYPE[id_abs]
    end
  end
end #/Taches
end #/Admin
