# encoding: UTF-8
class SiteHtml
class TestSuite
class Request

  # {String} La requête à exécuter
  attr_reader :request

  def initialize requete
    @request  = requete
  end

  # Exécute la requête
  #
  # RETURN L'instance requête courante {SiteHtml::Test::Request} par
  # convénience
  #
  def execute
    @content = `#{request} 2>&1`.force_encoding('utf-8')
    if @content.start_with?('Warning')
      error "# ERREUR CURL avec la requête #{request} : #{@content}"
      @content = ''
        # Ne pas mettre nil ci-dessus sinon la méthode `execute` serait
        # appelée chaque fois qu'on essaie d'obtenir le content.
    end
    return self
  end
  def ok?
    (code_retour == 200 && texte_retour.upcase == "OK") ||
    (code_retour =~ /30(1|2)/ && texte_retour.upcase == 'FOUND')
  end
  def error_404?
    code_retour == 404
  end

  # Code retourné par l'exécution de la requête
  def content
    execute if @content === nil
    @content
  end

  def header
    @header ||= begin
      content.match(/^HTTP\/(?:[0-9\.]+) ([0-9]{,3}) (.+?)Date/m).to_a.collect{|e| e.strip}
    end
  end
  def code_retour
    @code_retour ||= header[1].to_i
  end
  def texte_retour
    @texte_retour ||= header[2]
  end

end #/Request
end #/TestSuite
end #/SiteHtml
