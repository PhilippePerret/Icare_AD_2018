# encoding: UTF-8
=begin

  Pour simuler les routes

=end
class Simulate

  # Simuler une route
  #
  # +r+ La route complète à jouer
  # +options+   {Hash} des options
  #     :as_phil        Comme administrateur
  #     :as             Comme… 'Phil' = administrateur
  #     :params         {Hash} Ce qu'il faut passer en paramètres à l'application
  #     :query_string   Éventuellement le query-string, en string tout prêt
  #                     pour le moment.
  #
  # +params+  Éventuellement un Hash contenant les paramètres à mettre
  #           dans Param (donc qui doivent être accessibles par `param(:<key>)`)
  #
  def route r, options = nil, params = nil

    SiteHtml.reset_current

    test_procedure = options.delete(:test)

    options ||= Hash.new
    if options[:as_phil] || options[:as] == 'Phil'
      User.current = phil
    end

    # Définition des paramètres param
    params.key?(:user_id) || begin
      raise 'L’utilisation de `Simulate#route` ne peut se faire qu’avec un user défini par :user_id dans les paramètres (deuxième argument). Sinon, utiliser la méthode visit simple.'
    end

    app.curl_as_user( r, params )

  end
end #/Simulate
