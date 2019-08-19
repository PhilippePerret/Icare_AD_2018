# encoding: UTF-8

require 'cgi/session'
class App

  def session
    @session ||= begin
      sess = CGI::Session::new(
        page.cgi,
        'session_key'       => cookie_name,
        'session_expires'   => Time.now + 60 * 60,
        'prefix'            => 'icaress'
      )
      sess
    end
  end

  def cookie_name
    @cookie_name ||= site.cookie_session_name || "SESSRESTSITEWTB"
  end
  
  def delete_last_session
    sess = CGI::Session.new(page.cgi, 'new_session' => false)
    sess.delete
  rescue ArgumentError
    # S'il n'y a pas encore de session
  end
end
