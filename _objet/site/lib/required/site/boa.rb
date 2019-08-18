# encoding: UTF-8
class SiteHtml

  # RETURN Un hash des données de la citation choisie
  #
  # +options+ Surtout pour l'administration
  #   :no_last_sent     Si true, on n'actualise pas la date de dernier envoi
  #   :only_online      Si true, renvoie nil quand on est OFFLINE
  def get_a_citation options = nil
    options ||= Hash.new
    options[:only_online] && OFFLINE && (return nil)
    client =
      if OFFLINE
        client_boa('scenariopole_biblio') # ensuite : _biblio
      else
        client_boa('boite-a-outils_biblio') # ensuite : _biblio
      end
    candidates = client.query("SELECT id, citation, auteur FROM citations ORDER BY last_sent ASC LIMIT 10 OFFSET 11;")
    candidates = candidates.collect{|row| row}
    candidate = candidates.shuffle.shuffle.first.to_sym
    options[:no_last_sent] || begin
      client.query("UPDATE LOW_PRIORITY citations SET last_sent = #{Time.now.to_i} WHERE id = #{candidate[:id]};") rescue nil
    end
    return candidate
  end

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client_boa db_boa_name
    @client ||= begin
      Mysql2::Client.new(client_data_boa.merge(database: db_boa_name))
    end
  end
  def client_data_boa
    data_mysql_boa[ONLINE ? :online : :offline]
  end
  def data_mysql_boa
    @data_mysql_boa ||= begin
      require './data/secret/mysql_boa'
      DATA_MYSQL_BOA
    end
  end

end
