# encoding: UTF-8

Dir["./lib/deep/deeper/module/ranking/lib/**/*.rb"].each{|m| require m}

feature "Page ranking" do
  before(:all) do

    # # Pour reprendre tous les checks, décommenter la ligne ci-dessous
    # # Si elle n'est pas décommentée, la recherche reprendra sur les
    # # dernier mot-clé qui n'a pas été checké, afin de ne jamais tout
    # # reprendre depuis le début (ce qui prend beaucoup de temps)
    # Ranking.reset_data

  end

  after(:all) do
    # À la fin de l'opération, on construit et on ouvre le
    # fichier report
    Ranking.build_html_file(open: true)
  end

  # On boucle sur les mots-clés tant qu'on doit les traiter.
  # Noter que lorsque tous les mots clés ont été traités et enregistrés
  # dans le fichier Marshal, il n'y a plus rien à traiter.
  Ranking.keywords_undone. each do |keyword|

    scenario "Recherche des meilleures pages du mot “#{keyword}”" do

      test "Recherche site sur meilleures premières pages de #{keyword}"

      @rank = Ranking.new(keyword)
      kw = CGI.escape(keyword)

      visit "http://google.fr/search?q=#{kw}"
      index_page = 0

      begin

        # Début de boucle sur les 20 premières pages, les seuls qu'on
        # analyse
        while true

          index_page += 1

          # On pause en attendant de
          # Mettre '10' plutôt que '5' s'il y a des problèmes
          pause = 5 + (rand(200).to_f / 10)
          sleep pause

          # ====================================================== #
          # On analyse la page courante
          gpage = Ranking::GooglePage.new(@rank, index_page, page)
          gpage.analyze
          # ====================================================== #

          # Sur chaque page on quitte un lien
          cwl = gpage.current_window_location
          puts "current_window_location = '#{cwl}'"

          # On clique le lien aléatoire
          random_link = gpage.randon_clicked_link
          puts "Lien aléatoire de page #{index_page} : #{random_link}"
          gpage.all_founds[random_link].find('a').click
          # On patiente 4 secondes
          sleep 4 + rand(4)
          # On revient à la page de recherche de google
          visit cwl
          # On patiente 4 secondes
          sleep 4 + rand(4)
          puts "On a pu aller à la page et en revenir."


          has_bouton_suivant = false
          within('div#foot[role="navigation"]'){has_bouton_suivant = page.has_link?('Suivant')}
          if has_bouton_suivant
            within('div#foot[role="navigation"]'){click_link "Suivant"}
          else
            has_lien_all_resultats =
              within('div#extrares'){page.has_link?('relancer la recherche pour inclure les résultats omis')}
            if has_lien_all_resultats
              within('div#extrares') do
                click_link 'relancer la recherche pour inclure les résultats omis'
                @rank.reset_resultats
                index_page = 0
              end
            end
          end

          # break # pour tester seulement une page

          # Faut-il s'arrêter là
          if index_page == 20
            # On peut s'arrêter ici
            break
          elsif page.has_content?('À propos de cette page')
            # On s'arrête dès qu'on rencontre la dernière page des meilleurs
            # résultats
            break
          end

        end
        # /boucle sur toutes les pages

      rescue Exception => e
        puts "# ERREUR : #{e.message}\n" + e.backtrace.join("\n")
      ensure
        # Finaliser le résultat et l'enregistrer dans le fichier
        # marshal
        puts "--> @rank.finalise_resultats"
        @rank.finalise_resultats
        puts "<-- @rank.finalise_resultats"
        puts @rank.result
        # puts @rank.report
      end
    end
    # /fin du test sur le mot-clé courant

    # break # fin pour essai

  end
  # / Boucle sur chaque mot-clé

  # Scénario
end
