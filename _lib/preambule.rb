# encoding: UTF-8
=begin

Préambule de l'application, après que tout a été chargé

=end
def execute_preambule
  app.benchmark('-> execute_preambule')
  app.flash_dessessionnalize # les messages mis en session quand redirection
  app.check_ticket
  app.check_curl_as_user
  app.check_visit_as_user
  user.do_after_load
  app.benchmark('<- execute_preambule')
end
