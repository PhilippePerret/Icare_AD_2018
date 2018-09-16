# encoding: UTF-8
=begin

Module des données du livre

=end
def livre
  @livre ||= LaTexBook::current
end
alias :book :livre

class LaTexBook

  # Définies par "livre.<variable>"

  # {String} Path du dossier contenant :
  #   - les sources
  #   - le fichier tdm (if any)
  attr_accessor :sources_folder

  # {String} Nom (affixe) du fichier PDF
  # "latexbook" par défaut
  attr_accessor :pdf_name

  # {Boolean} Pour demander l'ouverture du fichier
  attr_accessor :open_it

  # {TrueClass|FalseClass} Pour déterminer si le livre doit
  # être fait en version féminine ou non
  #
  # Rappel, pour utiliser la version féminine, utilliser dans le
  # code Markdown des commandes latex `\fem{...}`
  #
  def version_femme
    @version_femme ||= false
  end
  def version_femme= value
    @version_femme = value
  end

  def reset_variables
    @pre_code_markdown_file = nil
    @version_femme          = nil
    @pdf_name               = nil
    @pdf_file               = nil
    @suffixe_version        = nil
    @main_folder            = nil
  end
end #/LaTexBook
