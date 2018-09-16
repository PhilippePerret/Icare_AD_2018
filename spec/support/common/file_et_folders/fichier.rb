# encoding: UTF-8
def le_fichier path, options = nil
  Fichier.new path, options
end

require_relative 'module_methodes.rb'

class Fichier
  include MethodesDossiersFichiers

  def initialize path, options
    @path = path
    @options = options
  end
  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #  Méthodes fonctionnelles
  # ---------------------------------------------------------------------
  def designation
    @designation ||= "Le fichier `#{path}'"
  end
  
end #/Fichier
