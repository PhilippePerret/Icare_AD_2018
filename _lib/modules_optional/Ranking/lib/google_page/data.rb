# encoding: UTF-8
class Ranking
  class GooglePage

    # Les données, pour enregistrement dans les résultats
    #
    def data
      {
        # L'index de la page dans la recherche google
        index: index,
        # Le chemin d'accès dans lequel est enregistrée le code complet
        # de la page
        file_path:  file_path,
        # Le mot clé recherché avec cette page
        keyword:    searched
      }
    end
  end #/GooglePage
end #/Ranking
