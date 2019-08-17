# encoding: UTF-8
require_relative 'module_methodes.rb'

def le_dossier path, options = nil
  Dossier.new(path, options)
end


class Dossier
  include MethodesDossiersFichiers
  attr_reader :path
  attr_reader :options
  def initialize path, options
    @path     = path
    @options  = options
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def contient_le_fichier fname, options = nil
    fpath = File.join(path,fname)
    if File.exist?(fpath)
      if File.directory?(fpath)
        raise "#{designation} contient un élément `#{fname}' mais c'est un dossier."
      else
        success "#{designation} contient le fichier `#{fname}'."
      end
    else
      raise "#{designation}  ne contient pas le fichier `#{fname}'."
    end
  end
  def contient_le_dossier fname, options = nil
    fpath = File.join(path,fname)
    if File.exist?(fpath)
      if File.directory?(fpath)
        success "#{designation} contient le dossier `#{fname}'."
      else
        raise "#{designation} contient un élément `#{fname}' mais ce n'est pas un dossier."
      end
    else
      raise "#{designation} ne contient pas le dossier `#{fname}'."
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------
  def designation ; @designation ||= "Le dossier `#{path}'" end

end#/Dossier
