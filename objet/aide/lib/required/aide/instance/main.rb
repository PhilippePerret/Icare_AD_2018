# encoding: UTF-8
class Aide

  attr_reader :id

  def initialize id
    @id = id
    # Pour forcer le calcul des noms, etc. et voir
    # si le fichier existe.
    fpath
  end

  def output
    # inspect
    case fextension
    when '.md'
      site.require_module('Kramdown')
      fpath.kramdown
    when '.erb'
      fpath.deserb
    when '.html', '.htm'
      fpath.read
    else
      fpath.read
    end
  end

  def inspect
    debug "fpath : #{fpath}"
    debug "fname: #{fname.inspect}"
    debug "fextension : '#{fextension}'"
  end

  def fname ; @fname end
  def fextension ; @fextension end
  def fpath
    @fpath ||= begin
      rs = Dir.glob("#{self.class.folder_textes}/#{id}-*")[0]
      rs != nil || raise("Le fichier d'aide commençant par `#{id}-` est introuvable")
      @fname      = File.basename(rs)
      @fextension = File.extname(rs)
      self.class.folder_textes + @fname
    end
  end
end
