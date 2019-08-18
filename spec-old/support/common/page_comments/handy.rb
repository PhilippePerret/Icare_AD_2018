
# Détruire tous les commentaires de page
#
# Cette opération est appelée à la fin de la suite des tests
def remove_page_comments
  Page::Comments.table.delete
end

# Créer des commentaires de pages
#
# +args+
#     Peut être soit le nombre de commentaires à créer, soit
#     des données définissant le nombre de commentaire
#
#     :nombre       Nombre de commentaires à créer (15 par défaut)
#     :route        La route ou pris au hasard
#     :valided      Le nombre de commentaires validés
#                   Ou :all pour tous, :none pour aucun
#
def create_page_comments args

  auteur, route, valided = [nil, nil, nil]

  case args
  when Integer
    # => le nombre de commentaires de pages
    nombre = args.freeze
  when Hash
    # => Des infos plus complète
    nombre  = args[:nombre] || 15
    route   = args[:route]
    valided = args[:valided]
  end

  data_users = [
    {pseudo: "Marion",  id: 3},
    {pseudo: "Benoite", id: 2},
    {pseudo: 'Phil',    id: 1}
  ]
  routes = [
    'calculateur/main', 'forum/home', 'cnarration/home',
    'article/2/show', 'page/30/show?in=cnarration', 'analyse/home',
    'analyse/10/show'
  ]
  nombre_routes = routes.count

  prev_is_valided = false
  nombre.times.each do |itime|

    puts "itime comment : #{itime}"
    # L'auteur du commentaire : soit celui spécifié,
    # soit un utilisateur au hasard
    u =
      case auteur
      when NilClass then data_users[rand(3)]
      else auteur
      end

    unedate = Time.now.to_i - rand(10000)

    # La route : soit celle spécifiée, soit une route
    # au hasard
    uneroute =
      case route
      when NilClass then routes[rand(nombre_routes)]
      else route
      end

    bit1_options =
      case valided
      when Integer
        valided -= 1
        valided > 0 ? '1' : '0'
      when :all   then '1'
      when :none  then '0'
      else
        prev_is_valided = !prev_is_valided
        prev_is_valided ? '1' : '0'
      end

    dcom = {
      user_id:      u[:id],
      pseudo:       u[:pseudo],
      route:        uneroute,
      comment:      "Un commentaire de #{u[:pseudo]} du #{Time.at(unedate)}",
      options:      "#{bit1_options}0000000",
      created_at:   unedate,
      updated_at:   unedate
    }
    if prev_is_valided
      dcom.merge!(
        votes_up:     rand(20),
        votes_down:   rand(10)
      )
    end
    Page::Comments.table.insert(dcom)
    puts "Commentaire #{dcom.inspect} inséré."
  end

end
