# encoding: UTF-8
=begin
Le code total de sortie de la page
=end
require 'erb'

class SiteHtml

  # Objet bindé à la vue.
  # Ça peut être trois choses, dans l'ordre :
  #   1. L'instance de la classe définie par la route (if any)
  #   2. La classe définie par la route (if any)
  #   3. Le site
  def objet_binded
    @objet_binded ||= begin
      bindee = nil
      bindee = current_route.sujet unless current_route.nil?
      bindee || site
    end
  end

  # Retourne TRUE si c'est une requête Ajax
  # @usage      if site.ajax? ...
  def ajax?
    @is_ajax = ( param(:ajx).to_s == "1" ) if @is_ajax === nil
    @is_ajax
  end

  def output
    app.benchmark('-> SiteHtml#output')
      # Note : la fin du benchmark de cette méthode sera mis
      # dans page.output, car on ne passe pas à la fin de cette
      # méthode.
    execute_route
    page.preload
    page.prebuild_body
    page.output
    # On ne passe jamais ici
  rescue Exception => e
    # ERREUR FATALE
    app.benchmark_fin rescue nil
    m = "<html><head><meta content='text/html; charset=utf-8' http-equiv='Content-type' /></head><body>" +
    "<div style='color:red;padding:2em;font-size:17.2pt'>" +
    "<div>Houps !… Une erreur est malheureusement survenue…</div>" +
    "<div>ERREUR : #{e.message.gsub(/</,'&lt;')}</div>" +
    e.backtrace.collect { |m| "<div>#{m.gsub(/</,'&lt;')}</div>" }.join +
    "</div></body></html>"
    STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
    STDOUT.write m
    begin
      # On essaie de récupérer le debug
      dbg_file = File.join('.', 'debug.log')
      if File.exist?(dbg_file)
        dbg = File.open(dbg_file, 'r'){|f| f.read.force_encoding('utf-8')}
        STDOUT.write "<pre style='white-space:pre-wrap;font-size:15pt;'>\n\n=== DEBUG.LOG ===\n#{dbg}\n</pre>"
      end
    rescue Exception => e2
      if OFFLINE
        STDOUT.write "<div>Malheureusement, je n'ai pas pu récupérer le fichier debug : #{e2.message}</div>"
      end
    end
  end

  def bind; binding() end

end
