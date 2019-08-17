# encoding: UTF-8
=begin

  Méthode concernant la commande Curl

=end
class TestedPage
  # Soumet la command CURL et retourne le résultat (brut, c'est
  # dans la méthode appelante que l'encodage sera forcé, par exemple
  # et que le code sera testé/validé)
  def retour_curl_commande
    `#{curl_command}`
  end

  # Fabrication de la commande CURL
  #
  # L'url peut contenir des données, etc., que la commande fait
  # passer dans --data
  def curl_command
    # say "Commande curl jouée : #{real_curl_url}"
    # say "Avec données : #{real_curl_data.inspect}"
    @curl_command ||= begin
      if real_curl_data.nil?
        "curl -s #{real_curl_url}"
      else
        "curl -s --data \"#{real_curl_data}\" #{real_curl_url}"
      end
    end
  end

  # La "vraie" url qui va être utilisée par la commande CURL, en fonction
  # des paramètres du site
  def real_curl_url
    @real_curl_url ||= begin
      curl_url, @real_curl_data = url.split('?')

      # Si les données de particularité de route définissent quelque chose
      # en fonction du context (paramètre 'in')
      if DATA_ROUTES.key?(:context)
        # Si la propriété définissant les particularités des routes
        # définit quelque chose pour le contexte courant de la route courante
        if DATA_ROUTES[:context].key?(context)
          dcontext = DATA_ROUTES[:context][context]
          curl_url = ajouts_curl_from_data_routes curl_url, dcontext
        end
      end
      # /Fin de si DATA_ROUTES définit la clé :context
      if DATA_ROUTES.key?(:objet)
        # Si la propriété définissant les particularités des routes
        # (DATA_ROUTES) définit quelque chose pour l'objet (premier mot
        # de la route) courant, il faut le traiter
        if DATA_ROUTES[:objet].key?(objet)
          dobjet = DATA_ROUTES[:objet][objet]
          curl_url = ajouts_curl_from_data_routes curl_url, dobjet
        end
      end
      # /Fin de si DATA_ROUTES définit la clé :objet
      curl_url
    end
  end
  def ajouts_curl_from_data_routes curl_url, data_ajout

    # Ajout à l'url envoyé par Curl
    if data_ajout.key?(:add_to_url)
      curl_url += dcontext[:add_to_url]
    end
    # Ajout aux données transmise par Curl
    if data_ajout.key?(:add_to_data_url)
      if @real_curl_data.nil?
        @real_curl_data = data_ajout[:add_to_data_url]
      else
        @real_curl_data += "&#{data_ajout[:add_to_data_url]}"
      end
    end
    return curl_url
  end


  def real_curl_data
    @real_curl_data || real_curl_url
    @real_curl_data
  end

  # Retourne la commande Curl pour obtenir l'entête seulement
  # d'une page hors-site.
  # Ici, avec -I, on ne peut pas passer de --data, donc il n'y a
  # plus qu'à espérer que ça fonctionne.
  def curl_command_header_only
    @curl_command_header_only ||= begin
      justurl, data = url.split('?')
      "curl -I -s #{url}"
    end
  end

end #/TestedPage
