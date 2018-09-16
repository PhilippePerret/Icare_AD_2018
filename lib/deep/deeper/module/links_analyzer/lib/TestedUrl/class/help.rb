# encoding: UTF-8
class TestedPage
  class << self

    # = main =
    #
    # Code retourné lorsqu'on demande l'aide sur le programme
    #
    # Note : Ça ne fonctionne qu'en ligne de commande.
    # @usage :      main.rb -h
    #
    # ATTENTION : Ce module peut être appelé tout seul (pour obtenir
    # l'aide en console par exemple), donc il ne doit pas faire appel
    # à d'autres méthodes (ou alors les charger).
    #
    def help
      say <<-TXT


#{'='*80}
= AIDE DE LINKS ANALYZER EN LIGNE DE COMMANDE =
#{'='*80}

main.rb[ <options>]

  -o/--online         Test en online. Sinon, le test est fait sur
                      le site local (localhost)
  -v/--verbose        Verbosité des retours
  -h/--help           Afficher cette aide
  --fail-fast         L'analyzer s'arrête dès qu'une erreur
                      est rencontrée sur une page.
  -d=…/--depth=…      Profondeur de la recherche. Plus le nombre
                      est grand, plus on recherche profondément dans les
                      liens de pages de pages de pages, etc.
  -r=…/--from-route=…
                      Route de départ pour la recherche. Par défaut
                      c'est l'accueil du site, qui doit se trouver
                      sur la route `site/home'.
                      L'argument doit être une route valide, avec des
                      arguments possibles : `page/32/show?in=cnarration'
  -f=…/--report-format=…
                      Format de sortie du rapport. Pour le moment, ne peut
                      être que :
                        html      Fichier HTML
                        brut      Sortie en console
  -m=…/--max-routes=…
                      Nombre de routes maximum qui doivent être checkées.
                      Utile surtout pour les tests de l'analyzer.
  -D/--dumped-data    Reprendre les données consignées dans le fichier Marshal
                      lors de la dernière analyse.
  -x/--code-html      Si présent, on ajoute le code HTML des pages erronées.
                      False par défaut, ça prend de la place et ça n'est pas
                      toujours utile.

  EXEMPLES
  --------

      #{'-'*60}
      Analyser seulement les liens de la page correspondant à la
      route `ma/route'

        main.rb --from-route=ma/route --depth=1

      Version raccourcie :

        main.rb -r=ma/route -d=1 -x

        # Le '-x' permet d'afficher le code HTML de la page si elle
        # est erronée.

      #{'-'*60}
      Reprendre les données consignées dans la dernière analyse et
      sortir le rapport en console

          main.rb -D -f=brut

#{'='*80}
      TXT
    end

  end #/<< self
end #/TestedPage
