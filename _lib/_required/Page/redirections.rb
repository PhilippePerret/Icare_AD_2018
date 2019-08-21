# encoding: UTF-8
class Page

  # Pour faire une vraie redirection
  def redirect_to route
    puts cgi.header(status: '303', location: "#{site.url}/#{route}")
  end

end #/Page
