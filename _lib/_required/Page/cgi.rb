# encoding: UTF-8
=begin
Partie CGI de la page
=end
require 'cgi'
class Page
  def cgi
    @cgi ||= CGI.new('html4')
  end
end
