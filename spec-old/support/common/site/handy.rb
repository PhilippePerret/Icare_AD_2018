# encoding: UTF-8
def execute_route route_init
  unless route_init.nil?
    if route_init.match(/\?in/)
      route, context = route_init.split('?in=')
    else
      route = route_init
      context = nil
    end
    objet, identifiant, method = route.split('/')
    if method.nil?
      method      = identifiant.freeze
      identifiant = nil
    end
  else
    objet, method, identifiant, context = nil, nil, nil, nil
  end
  [:route, :current_route, :objet].each do |var|
    site.instance_variable_set("@#{var}", nil)
  end
  {
    :__o  => objet,
    :__m  => method,
    :__i  => identifiant,
    :in   => context
  }.each do |kparam, valparam|
    param(kparam => valparam)
  end
end
