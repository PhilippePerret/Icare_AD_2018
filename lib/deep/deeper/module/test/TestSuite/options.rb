# encoding: UTF-8
class SiteHtml
class TestSuite

  attr_reader :options

  def parse_options
    @options ||= Hash.new
    @options.merge!(debug: false) unless @options.has_key?(:debug)
    # debug "SiteHtml::Test::options : #{@options.pretty_inspect}" if debug?
    self.class::options = @options.delete(:options)
  end

  # Méthode appelée juste avant de lancer véritablement les
  # tests pour régulariser les options
  def regularise_options
    # Les deux options :online et :offline sont requises
    if @options.has_key?(:online) && !@options.has_key?(:offline)
      @options.merge!(offline: !@options[:online])
    elsif @options.has_key?(:offline) && !@options.has_key?(:online)
      @options.merge!(online: !@options[:offline])
    end
  end

  # Enregistrement d'option
  #
  # Quelques ajustements sont exécutés si nécessaire.
  def options= hdata
    @options ||= Hash.new
    @options.merge! hdata
    regularise_options
  end

end #/TestSuite
end #/SiteHtml
