# encoding: UTF-8
=begin
Partie CGI de la page
=end
require 'cgi'
class Page

  def cgi
    @cgi ||= CGI.new('html4')
  end

  # Pour faire une vraie redirection
  def redirect_to route
    # Avant de rediriger la page, il faut voir si des messages sont
    # à conserver en session pour pouvoir les remettre.
    app.flash_sessionnalize
    puts cgi.header(status: '303', location: "#{site.url}/#{route}")
  end

end
