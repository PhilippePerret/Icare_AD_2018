# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def visualise_document_kramdown path, oformat = 'html'
    if File.exist? path
      # param(:pmd => path)
      # redirect_to 'admin/show_page_md'
      sub_log "-> Cliquer ici pour fabriquer et voir le fichier".in_a(target:'_blank', href:"admin/show_page_md?pmd=#{CGI::escape path}&format=#{oformat}")
      "OK"
    else
      error "Le fichier `#{path}` est introuvable. Merci de vérifier le path."
      "ERROR"
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
