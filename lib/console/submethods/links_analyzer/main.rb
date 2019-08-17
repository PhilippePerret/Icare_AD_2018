# encoding: UTF-8
# On aura besoin de ça pour afficher l'aide de lINKS ANALYZER
class TestedPage
  def self.say mess
    mess#.gsub(/\n/,'<br>')
  end
end

class SiteHtml
class Admin
class Console
  def test_all_pages options
    options = options.nil_if_empty
    cmd = "cd #{(site.folder_module + 'links_analyzer').expanded_path};\nruby main.rb #{options}".strip
    sub_log "COPIER-COLLER LA COMMANDE SUIVANTE DANS LE TERMINAL :<br><br>"
    sub_log cmd.in_textarea(style: 'width:98%;height:100px;padding:8px', onfocus: 'this.select()')
    require './lib/deep/deeper/module/links_analyzer/lib/TestedUrl/class/help.rb'
    sub_log '<pre class="small">' + TestedPage.help + '</pre>'
    # retour = `#{cmd} 2>&1`
    # sub_log "Retour du LINKS ANALYZER : #{retour.inspect}<br>"
    return ''
  end
end #/Console
end #/Admin
end #/SiteHtml
