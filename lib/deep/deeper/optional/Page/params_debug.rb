# encoding: UTF-8
=begin
Méthodes optionnelles pour les paragraphes de page
=end
class Page

  # Retourne tous les paramètres courants
  #
  def all_params
    hparams = query_string
    cgi.params.each do |k, v|
      hparams.merge! "[cgi] #{k.inspect}" => v
    end
    # # Session ?
    # App::session.instance_variable_get('@hash').each do |k, v|
    #   hparams.merge! "[session] #{k.inspect}" => v
    # end
    hparams
  end

  # Méthode de débug qui met dans le trace.log tous les
  # paramètres courants
  #
  def debug_params
    tous_parametres = all_params
    tous_parametres.merge! (@custom_params || {})
    if tous_parametres.empty?
      debug "[Page::debug_params] Paramètres courants : AUCUN"
    else
      debug "[Page::debug_params] Paramètres courants : "
      all_params.each do |k,v|
        debug "#{k.inspect} => #{v.inspect} (class #{v.class})"
      end
    end
    debug "App::session.inspect : #{App::session.inspect}"
  end

end
