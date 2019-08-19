# encoding: UTF-8
=begin
Facilités pour le jour courant

  Today.as_date         Le jour courant, comme Date

  Today.as_human_date[ options]
    {String} Le jour courant au format humain. Les mêmes options que
    la méthode de même nom de Time

  Today.as_jj_mm_yy[ delimiteur]
    {String} Le jour courant sous forme de "JJ MM YY"
    Si un délimiteur est spécifié, il sera mis entre les nombres

  Today.start
    {Integer} Le timestamp de la première seconde du jour courant

  Today.start_as_date
    {Time} Le début du jour courant, sous forme d'instance de date

  Today.end
    {Integer} Le timestamp de la dernière seconde du jour courant

  Today.end_as_date
    {Time} La fin du jour courant, sous forme d'instance de date

=end
class Today < Time
class << self

  def as_date
    @now ||= Time.now
  end
  alias :d :as_date

  def as_human_date options = nil
    @as_human_date ||= Time.now.to_i.as_human_date(options)
  end

  def as_jj_mm_yy delimiteur = " "
    as_date.strftime("%d#{delimiteur}%m#{delimiteur}%Y")
  end
  # Retourne le nombre de secondes du tout début du
  # jour courant
  def start
    @start ||= start_as_date.to_i
  end
  def start_as_date
    @start_as_date ||= Time.new(d.year, d.month, d.day, 0, 0, 0)
  end
  def end
    @end ||= end_as_date.to_i
  end
  def end_as_date
    @end_as_date ||= Time.new(d.year, d.month, d.day, 23, 59, 59)
  end
  def to_i
    @to_i ||= Time.now.to_i
  end
end #/self
end #/Today
