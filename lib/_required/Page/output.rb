# encoding: UTF-8
=begin

=end
class Page

  def bind
    binding()
  end

  def output
    unless site.ajax?
      # final_code = cgi.html{cgi.head{head}+cgi.body{body}}
      final_code = ERB.new(File.read('./_view/_site.erb').force_encoding('utf-8')).result(self.bind)
      app.benchmark('CODE HTML FINAL BUILT') rescue nil
      # Correspond aussi à la fin de la méthode output du site
      app.benchmark('<- SiteHtml#output')
      app.benchmark_fin #rescue nil
      cgi.out{final_code}
      # RIEN NE PEUT PASSER ICI
    else
      # Retour d'une requête ajax
      Ajax.output
    end
  end

  # Retourne TRUE si l'objet est une collection, pour schema.org,
  # comme une dictionnaire (scénodico) ou une liste comme filmodico.
  # Cela a pour effet d'ajouter "itemscope itemtype='http://schema.org/Collecion'"
  # dans la section de contenu de la page.
  #
  # @usage: utiliser page.is_collection pour définir que c'est une
  # collection.
  def collection?
    !!@is_collection
  end
  def is_collection value = true
    @is_collection = value
  end

  def ajout_schema_org
    if collection?
      ' itemscope itemtype="http://schema.org/Collection"'
    else
      ''
    end
  end

  # OBSOLÈTE : on utilise maintenant le module site.erb pour construire la
  # page complete
#   def head
#     @head ||= begin
#       with_fonts = !OFFLINE # Mettre ONLINE quand on ne peut pas avoir de connexion
#       fonts_google = if with_fonts
#         <<-FONTS
#         <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
#         <!--[if lt IE 9]>
#         <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
#         <![endif]-->
#         FONTS
#       else
#         ""
#       end
#       link_cssreset = OFFLINE ? '' : '<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.18.1/build/cssreset/cssreset-min.css">'
#       <<-HEAD
# <meta content="text/html; charset=utf-8" http-equiv="Content-type">
# <title>#{page.title}</title>
# <meta name="viewport" content="width=device-width, initial-scale=1">
# <link rel="shortcut icon" href="_view/img/favicon.ico?" type="image/x-icon">
# <link rel="icon" href="_view/img/favicon.ico?" type="image/x-icon">
# #{self.balise_meta_description}
# <base href="#{site.base}" />
# #{fonts_google}
# #{self.javascript}
# #{link_cssreset}
# #{self.css}
# <link rel="stylesheet" type="text/css" href="_view/css_speciaux/mobile.css" media="screen and (max-width: 800px)" />
# #{self.raw_css}
# #{self.raw_javascript}
#       HEAD
#     end
#   end

  def body
    @body ||= begin
      app.benchmark('-> Page#body')
      res = page.content
      app.benchmark('<- Page#body')
      res
    end
  end
  # /body

  def hotlinks
    @hotlinks ||= begin
      raise "Pas de vue 'hotlinks' dans le dossier gabarit"
      Vue.new('hotlinks', site.folder_gabarit).output
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE HOT-LINKS : #{e.message}]"
    end
  end
  # /hotlinks

end
