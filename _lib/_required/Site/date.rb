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

end #/SiteHtml
