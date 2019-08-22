# encoding: UTF-8
=begin

=end
class Page

  def bind
    binding()
  end

  def output
    unless site.ajax?
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

  def body
    @body ||= page.content
  end
  # /body

end
