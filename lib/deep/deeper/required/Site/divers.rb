# encoding: UTF-8
class SiteHtml

  def get_last_date cle, default_value = 0
    cle = cle.to_s
    res = table_last_dates.select(where: {cle: cle} ).first
    res.nil?  ? default_value : res[:time]
  end
  alias :get_last_time :get_last_date

  # Enregistrement de la clé +key+ avec le temps +time+
  def set_last_date cle, time = nil
    time ||= Time.now.to_i
    cle = cle.to_s
    table_last_dates.set( {where: {cle: cle} }, {time: time, cle: cle} )
  end
  alias :set_last_time :set_last_date

  # Exécute le script +script+ (qui doit être au format AppleScript)
  # RETURN False s'il y a eu une erreur (qui est affichée) ou
  # le retour du script qui peut contenir l'erreur AppleScript.
  def osascript(script)
    File.open("./.scriptprov.scpt",'wb'){|f| f.write(script)}
    res = `osascript ./.scriptprov.scpt 2>&1`
  rescue Exception => e
    error "# ERREUR : #{e.message}"
  else
    res
  ensure
    File.unlink("./.scriptprov.scpt")
  end


  # Ajoute une actualisation dans la table `updates' (cold)
  #
  # Cet ajout peut se faire de façon automatique ou par la
  # console.
  #
  # @syntaxe    site.new_update( data )
  # Pour les données, cf. le manuel
  def new_update data
    require_module 'updates'
    SiteHtml::Updates.new_update data
  end
end #/SiteHtml
