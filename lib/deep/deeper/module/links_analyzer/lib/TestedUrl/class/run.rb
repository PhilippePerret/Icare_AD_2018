# encoding: UTF-8
class TestedPage
  class << self

    # = main =
    #
    # Méthode principale appelée pour lancer l'analyse
    #
    def run
      puts '' # pour de l'air en console
      @start_time = Time.now.to_f
      init
      if (dumped_data? ? !get_data_from_marshal : true)

        # Pour le moment, on s'arrête toujours là
        if dumped_data?
          say 'Les données n’ont pas pu être récupérées donc je repasse par là (je m’arrête pour le moment).'
          return
        end

        links_analyze
        merge_similar_routes
        save_data_in_marshal
      end
      @end_time = Time.now.to_f
      puts "\n\n"
      return true
    rescue Exception => e
      debug "ERREUR FATALE DANS TestedPage::run : #{e.message}"
      debug e.backtrace.join("\n")
      return false
    end

    # = sous-main =
    #
    # Analyse récursive de tous les liens du site
    #
    def links_analyze

      @routes = [ options['from-route'] ]

      # On instancie la toute première TestedPage pour qu'elle
      # existe (dès qu'on trouve une route/href dans une page,
      # on instancie une TestedPage pour elle)
      tpage  = new(@routes.first)
      tpage.call_count = 1
      tpage.call_texts = [nil]
      tpage.call_froms = [nil]
      tpage.depths << 0

      # Index de la route testée, utile lorsque l'on indique une
      # limite de traitement.
      iroute_tested = 0

      # On boucle sur les routes tant qu'il y en a.
      while route = @routes.shift
        # say "ROUTE : #{route}"
        begin
          # Pour les essais, on interromp au bout d'un certain nombre de
          # routes testées
          iroute_max?( iroute_tested ) ? break : iroute_tested += 1

          # === TEST DE LA ROUTE ===
          if test_route route, iroute_tested
            # OK
          else
            # On passe ici quand `test_route` retourne false ou nil. Attention,
            # quand on reprogramme cette méthode, on peut avoir oublié de
            # retourner TRUE, ce qui va provoquer l'arrêt inopiné.
            # say "test_route a retourné FALSE => break pour fin"
            break
          end

        rescue Exception => e
          say "# ERREUR FATALE EN TESTANT LA ROUTE #{route.inspect} : #{e.message}"
          debug e
        end
      end
      # / Fin du while tant qu'il y a des routes
    end
    # / Fin de .links_analyze

    # Teste complet de la route +route+
    #
    # Retourne TRUE pour continuer de tester les routes, ou retourne
    # FALSE pour interrompre la boucle (cela arrêtera le test et lancera
    # l'écriture du rapport).
    #
    def test_route route, iroute_tested

      # La route complète, telle qu'enregistrée dans la liste
      # de toutes les routes à prendre
      # url = File.join(base_url, route)

      # On récupère l'instance de la TestedPage qui va
      # être traitée à présent
      testedpage = TestedPage[route]

      # Si la route doit être excluse, il ne faut pas la prendre
      # On doit retourner true pour ne pas interrompre la boucle
      return true if testedpage.has_route_excluded?

      # Si la route appartient à un dossier à exclure, il ne faut
      # pas la prendre. Noter que c'est surtout utile pour certains
      # fichiers spéciaux comme les analyses de films de type TM qui
      # ouvrent un fichier Html qui ne contient pas le gabarit de la
      # page.
      # Contrairement à la méthode has_route_excluded? ci-dessus, on
      # s'assure quand même que le fichier retourne un statut 200 si
      # cela est demandé dans la configuration.
      # On doit retourner true pour ne pas interrompre la boucle
      return true if testedpage.has_folder_excluded?

      # Si la profondeur maximum est définie et que la
      # page a une profondeur supérieure à cette
      # profondeur max, on ne la traite pas
      depth_max.nil? || testedpage.depth < depth_max || (return true)


      color = testedpage.valide? ? '32' : '31'
      if verbose? || infos?
        say "\e[1;#{color}m* #{iroute_tested} / #{@routes.count} * Tested route: #{route}\e[0m"
      else
        print "\e[1;#{color}m*\e[0m"
      end

      # On regarde si cette page est valide, si elle correspond
      # à ce qu'on attend d'elle.
      testedpage.valide? || begin
        # Quand la page n'est pas valide
        testedpage.set_invalide
        # Si FAIL_FAST est true, on doit interrompre la boucle à la
        # première erreur rencontrée et afficher l'erreur.
        # Sinon, on passe à la suite.
        if FAIL_FAST
          say "#{RETRAIT}### " + testedpage.errors.join("\n#{RETRAIT}### ")
          say "#{RETRAIT}### Commande curl: #{testedpage.curl_command}"
          say "#{RETRAIT}### <a href=\"#{testedpage.url}\">#{testedpage.url}</a>" # pour y aller directement
          say "\n\nCODE DE LA PAGE :\n#{testedpage.raw_code}"
          return false
        else
          return true
        end
      end

      # ---------------------------------------
      # Seules passent ici les pages valides.
      # ---------------------------------------

      # On ajoute à la liste des routes les routes appelées par
      # cette page, sauf si c'est une page à l'extérieur du
      # site lui-même
      unless testedpage.hors_site?
        self.links_count += testedpage.links.count
        testedpage.links.each do |link|
          # On ne prend pas les routes javascript
          next if link.javascript?

          # Une route appelée dans la page. Elle peut avoir déjà
          # été traitée ou non.
          new_route = link.href

          say "Linked to: #{new_route.inspect}" if infos?

          # On ne prend pas les routes qu'on a déjà traitées mais on
          # ajouter une valeur de présence et on passe à la suite.
          if exist?(new_route)

            # === UNE ROUTE CONNUE ===
            knownpage = TestedPage[new_route]
            knownpage.call_count += 1
            knownpage.call_texts << link.text
            knownpage.call_froms << testedpage.route
            knownpage.depths << testedpage.depth + 1

          else

            # === UNE ROUTE/HREF INCONNUE ===
            # Si c, il faut créer une rangée dans hroutes et
            # ajouter la route aux routes à tester
            new_tpage = new(new_route)
            new_tpage.call_count = 1
            new_tpage.call_texts << link.text
            new_tpage.call_froms << testedpage.route
            new_tpage.depths << testedpage.depth + 1
            @routes << new_route
          end

        end
        #/ Fin de boucle sur chaque lien trouvé dans la page
        #  courante testée

      end
      #/ Fin de si c'est une url hors de la base courante

      return true
    end
    #/ Fin de la méthode de test de la route .test_route


    def merge_similar_routes
      # Avant de faire l'évaluation, il faut tenir compte du
      # fait que certaines routes ont conduit à des instances
      # différentes, mais qu'il faut les compter comme une seule
      # dans la suite.
      # C'est le cas dès qu'il y a une ancre. Par exemple, les
      # routes :
      #   ma/route
      #   ma/route#une_ancre
      # … sont deux instances différentes et il le faut, puisque
      # la première est valide si la page est valide mais la
      # seconde est valide si l'ancre est trouvée dans la page
      # Ici, cependant, nous allons merger ces deux instances.
      # On se sert pour ça de leur paramètres 'route' qui est
      # forcément identique puisqu'il a été "purifié" à l'instanciation.
      liste_instances_with_anchor = Array.new
      instances.each do |route_init, tpage|
        # On ne traite que les TestedPage qui ont une ancre
        tpage.url_anchor != nil || next
        # Si une page existe avec la route simple (sans
        # l'ancre) on doit merger les deux pages et mémoriser
        # la route_init courant pour la détruire dans les
        # instances
        if instances.key?(tpage.route)
          # Une petite vérification au cas où : il ne faudrait
          # pas que ce soit le même objet !
          if instances[tpage.route].object_id == tpage.object_id
            debug "# IMPOSSIBLE DE MERGER LA ROUTE #{tpage.route}"
          else
            # On merge les deux instances
            instances[tpage.route].merge( tpage )
          end
        end

        # Ajouter cette route_init dans la liste des
        # instances à détruire
        liste_instances_with_anchor << route_init
      end
      # /Fin de boucle sur chaque instance

      # On détruit les instances à détruire
      liste_instances_with_anchor.each do |route_init|
        is_invalide = !TestedPage[route_init].valide?
        instances.delete(route_init)
        # Si la route est utilisée dans les invalides, il
        # faut la remplacer
        is_invalide || next
        offset = invalides.index(route_init)
        offset != nil || next
        invalides.delete_at(offset)
      end
      # /FIn de la liste des instances avec ancres

      # On en profite ici pour corriger la liste des invalides,
      # dans le cas où certains problèmes se seraient posés.
      # Les deux erreurs qui peuvent se produire sont :
      #   - deux routes identiques pas mergées
      #   - des routes vides
      @invalides = invalides.uniq
      @invalides = invalides.reject{|e| e == ''}

    end
    # / Fin de la méthode `merge_similar_routes`

    # Retourne TRUE si un nombre de routes à tester maximum a été
    # décidé et qu'il est atteint.
    #
    # Rappel : Le nombre se définit dans le fichier app.rb, comme
    # tout ce qui concerne l'application en propre.
    def iroute_max? ir
      !!(options['max-routes'] && ir > options['max-routes'])
    end


  end #/<< self
end #/TestedPage
