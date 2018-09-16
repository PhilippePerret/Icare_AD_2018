# encoding: UTF-8
class SiteHtml

  # Table contenant les dates de dernières actions
  #   key: La clé de la table
  #   time:  Le timestamp (nombre secondes depuis 1 1 1970)
  # @usage: Utiliser la méthode `get_last_date(key)` et
  # `set_last_date(key, value)` pour définir et récupérer des valeurs
  def table_last_dates
    @table_last_dates ||= self.dbm_table(:hot, 'last_dates')
  end

end
