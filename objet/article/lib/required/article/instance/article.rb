# encoding: UTF-8
class Article

  attr_reader :id

  def initialize id
    @id = id
  end

  def titre
    @titre ||= begin
      t =
        case extension
        when '.md'
          path.read.match(/^###(.*?)$/).to_a[1]
        when '.erb'
          path.read.match(/<h3>(.*?)<\/h3>/).to_a[1]
        else
          # Pour tous les autres formats, il faut absolument
          # une première ligne qui contienne :
          #   <!-- Le titre de l'article -->
          path.read.match(/<\!\-\-(.*?)\-\->/).to_a[1]
        end
      (t || 'Sans titre').strip
    end
  end

  def output
    case extension
    when '.md'
      site.require_module('Kramdown')
      path.kramdown
    when '.erb'
      path.deserb
    else # html, txt, etc.
      path.read
    end
  end

  # Retourne un extrait tronqué de l'article (pour
  # la page d'accueil)
  def extrait
    titre, texte = raw_output
    e = ("<strong>#{titre}</strong> - #{texte}")[0..270]
    o = e.rindex(' ')
    e[0..o] + ' […]'
  end

  # Le contenu textuel brut (pour l'accueil)
  # Retourne un Array contenant :
  #   [le titre, le contenu sans tag]
  def raw_output
    @raw_output ||= begin
      lines = path.read.split("\n")
      lines.shift
      [titre, lines.join(' ').strip_tags(' ')]
    end
  end

  def extension
    @extension = File.extname(path)
  end
  def name
    @name ||= File.basename(path)
  end
  def affixe
    @affixe ||= "#{id}".rjust(4,'0')
  end
  def path
    @path ||= begin
      pfolder = Article.folder_lib + "texte"
      p = Dir.glob("#{pfolder}/#{affixe}.*")[0]
      p != nil || raise("Impossible de trouver l'article de nom #{affixe}…")
      SuperFile.new(p)
    end
  end

end
