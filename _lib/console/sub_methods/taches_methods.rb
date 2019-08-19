# encoding: UTF-8
=begin
Méthodes pour les taches
=end
class SiteHtml
class Admin
class Console

  class Taches
  class << self
    def sub_log str; console.sub_log str end

    # Marquer une tache finie
    #
    # Note : Produit aussi l'affichage des tâches de
    # l'admin courant.
    def marquer_tache_finie tache_id
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itask = ::Admin::Taches::Tache::new(tache_id.to_i)
      mess = if itask.exist?
        if itask.ended?
          "La tache #{tache_id} est déjà terminée."
        else
          itask.stop
          "Tache #{tache_id} marquée terminée."
        end
      else
        "La tache #{tache_id} n'existe pas."
      end
      show_liste_taches( admin: user.id )
      return "#{mess}\n# (`mes taches` => liste de vos taches)."
    end

    # Pour détruire la tache d'id +tache_id+
    # Noter que la destruction détruit vraiment la tâche, ne la marque
    # pas fini. Elle disparaitra complètement.
    def detruire_tache tache_id
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itask = ::Admin::Taches::Tache::new(tache_id.to_i)
      mess = if itask.exist?
        itask.destroy
        "Tache #{tache_id} détruite avec succès."
      else
        "La tache #{tache_id} n'existe pas."
      end
      show_liste_taches( admin: user.id )
      return "#{mess}\n# (taper `list taches` pour voir la liste des taches)."
    end


    # Créer un nouvelle tache en partant des données string
    # +data_str+ envoyées en argument
    def create_tache data_str
      site.require_objet 'admin'
      ::Admin.require_module 'taches'
      data_tache = PHData.by_semicolon_in data_str
      data_tache.merge!(updated_at: Time.now.to_i)
      itache = ::Admin::Taches::Tache.new
      itache.instance_variable_set('@data2save', data_tache)
      itache.data2save_valid? || ( return "Error" )
      # Les données sont valides, on peut enregistrer la tâche
      # Note : C'est la méthode create qui affichera le message
      # de réussite
      itache.create
      show_liste_taches( admin: user.id )
      return "`mes taches` => votre liste de tâches / `list taches` => liste des tâches à faire."
    end

    # Actualise la tache d'ID +tache_id+ avec les nouvelles
    # données +tache_data+
    def update_tache tache_id, tache_data_str
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itache = ::Admin::Taches::Tache::new(tache_id)
      raise "Cette tache est inconnue." unless itache.exist?

      # On transforme les données string en hash de données
      htache = PHData::by_semicolon_in tache_data_str

      # On fait quelques corrections et vérifications
      htache.merge!(echeance: htache.delete(:le)) if htache.key?(:le)
      if htache.has_key?(:echeance)
        htache[:echeance] = itache.test_echeance_tache(htache[:echeance])
        raise "Impossible d'actualiser la tache." if htache[:echeance] === false
      end
      if htache.key?(:pour)
        admin_id = htache.delete(:pour)
        unless admin_id.numeric?
          admin = User::get_by_pseudo(admin_id)
          raise "L'administrateur #{admin_id} est inconnu" if admin.nil?
          admin_id = admin.id
        end
        admin_id = admin_id.to_i
        htache.merge!(admin_id: admin_id)
      end
      htache.merge!(state: htache.delete(:statut)) if htache.key?(:statut)
      if htache.key?(:state)
        htache[:state] = itache.test_statut_tache(htache[:state])
        raise "Impossible d'actualiser la tache." if htache[:state] == false
      end

      # On peut actualiser la tache
      htache.merge!(updated_at: Time.now.to_i)
      itache.set(htache)

    rescue Exception => e
      debug e
      error e.message
      "ERROR"
    else
      show_liste_taches( admin: user.id )
      "Tache #{itache.id} actualisée."
    end


    # Affiche la liste de taches
    # +options+
    #   :all  Si true => toutes les taches même les taches achevées
    #   :admin  Si défini, l'id (string) ou le pseudo de l'administrateur
    #           dont il faut voir les tâches
    def show_liste_taches options = nil
      options ||= Hash.new
      site.require_objet 'admin'
      ::Admin::require_module 'taches'

      # On relève la liste des tâches
      task_list =
      if options[:all]
        sub_log "liste de toutes les taches".in_h3
        ::Admin.table_taches.select(order: "echeance DESC, state DESC", colonnes:[]).collect do |htache|
          ::Admin::Taches::Tache.new(htache[:id])
        end
      elsif options.key?( :admin )
        unless options[:admin].to_s.numeric?
          admin = User.get_by_pseudo(options[:admin])
          if admin.pseudo == "Marion" && admin.options[0..1] != "15"
            opts = admin.options
            opts[0..1] = "15"
            admin.set(options: opts)
          end
          raise "Aucun user ne porte le pseudo #{options[:admin]}" if admin.nil?
          raise "#{admin.pseudo} n'est pas administrateur/trice" unless admin.admin?
          options[:admin] = admin.id # OK
        else
          admin = User::get(options[:admin].to_i)
        end
        sub_log "liste des taches de #{admin.pseudo}".in_h3
        ::Admin::Taches.new.taches.collect do |itache|
          next if itache.admin_id != admin.id
          itache
        end.compact
      else
        sub_log "liste des taches en cours".in_h3
        ::Admin::Taches.new.taches
      end

      # Format de l'affichage, en fonction du lecteur
      format_ligne =
        if options.key?(:admin)
          "<div class='small%{css}'>T.%{tid} %{tache}%{file}</div><div class='right tiny'>Échéance : %{echeance} — %{reste}</div>"
        else
          "<div class='small%{css}'>T.%{tid} %{tache}%{file}</div><div class='right tiny'>Pour : %{owner} - Échéance : %{echeance} — %{reste}</div>"
        end

      if task_list.count > 0
        # Pour mettre la liste des tâches
        # Rappel : c'est maintenant un ensemble de quatre groupes :
        # - les tâches dont l'échéance a été dépassée,
        # - les tâches qui doivent être accomplies dans la journée
        # - les tâches avec échéance à accomplir plus tard
        # - les tâches sans échéance.
        # des tâches à faire plus tard.
        lt = {
          overrun:  Array.new,
          today:    Array.new,
          proche:   Array.new,
          futur:    Array.new,
          sans:     Array.new # Sans échéance
        }
        task_list.collect do |itask|
          owner     = itask.admin.pseudo
          css =
            if itask.state < 3    then ' discret'
            elsif itask.state < 6 then ' important'
            else ' prioritaire'
            end
          has_echeance = !!itask.echeance
          echeance  =
            if itask.echeance
              Time.at(itask.echeance).strftime("%d/%m/%y")
            else
              "aucune"
            end
          # S'il y a un fichier associé à la tache
          thefile =
            if itask.file.nil_if_empty != nil
              if File.exist? itask.file
                # Si file est un fichier
                nfile = File.basename(itask.file)
                lien.edit_file(itask.file, titre: " - ouvrir “#{nfile}”")
              else
                # Si file est une route
                " - rejoindre la route #{itask.file}".in_a(href: itask.file)
              end
            else
              ''
            end

          # Pour savoir où ranger la tâche
          reste =
            if itask.echeance
              r = ( (itask.echeance - Time.now.to_i) / 1.day ) + 1
              if r == 0
                etat = :today
                "doit être finie aujourd'hui".in_span(class:'blue')
              elsif r > 0
                etat = r > 7 ? :futur : :proche
                "dans #{r} jour#{r > 1 ? 's' : ''}"
              else
                etat = :overrun
                "devrait être finie depuis #{r} jour#{r > 1 ? 's' : ''}".in_span(class:'warning')
              end
            else
              etat = :sans
              "---"
            end

          t = (
            format_ligne % {tid: itask.id, tache: itask.tache, file: thefile, echeance: echeance, owner: owner, reste: reste, css: css}
          ).in_div

          lt[etat] << t
        end #/fin de la boucle

        # Construction du listing définitif
        listing = String.new
        lt[:overrun].empty? || begin
          listing << lt[:overrun].join('').in_fieldset(legend: "En dépassement d'échéance", class: 'overrun')
        end
        lt[:today].empty? || begin
          listing << lt[:today].join('').in_fieldset(legend: "À finir aujourd'hui", class: 'today')
        end
        lt[:proche].empty? || begin
          listing << lt[:proche].join('').in_fieldset(legend: "Tâches proches", class: 'proche')
        end
        lt[:futur].empty? || begin
          listing << lt[:futur].join('').in_fieldset(legend: "Tâches futures", class: 'futur')
        end
        lt[:sans].empty? || begin
          listing << lt[:sans].join('').in_fieldset(legend: "Sans échéance", class: 'sans_echeance')
        end


      else
        listing = "Aucune tâche trouvée."
      end
      sub_log listing
      return ""
    end


  end # << SELF
  end #/Taches
end #/Console
end #/Admin
end #/SiteHtml
