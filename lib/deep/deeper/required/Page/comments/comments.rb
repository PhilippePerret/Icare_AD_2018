# encoding: UTF-8
=begin

  Les commentaires en tant que liste

=end
class Page
class Comments
  class << self

    # = main =
    #
    # Retourne le code Html UL pour la liste des commentaires, ou
    # simplement le commentaire "Aucun commentaire pour le moment."
    def ul_current_route_comments
      allcoms = current_route_comments
      if allcoms.empty?
        'Cette page n’a fait l’objet d’aucun commentaire pour le moment.'.in_div(id: 'div_no_page_comment')
      else
        current_route_comments.collect do |comment|
          comment.as_li
        end.join.in_ul(id: 'ul_page_comments') + lien_autres_page_comments
      end
    end

    #
    def lien_autres_page_comments
      whereclause = "route = '#{site.current_route.route}'"
      user.admin? || whereclause += " AND SUBSTRING(options,1,1) = '1'"
      nombre_comments = table.count(where: whereclause)
      return '' if all_comments? || nombre_comments < 21
      # S'il y a plus de 20 commentaires et qu'il ne faut pas tous les
      # afficher, on propose un lien vers la même page qui afficherait
      # tous les commentaires de la page
      href = site.current_route.route
      href += href.include?('?') ? '&' : '?'
      href += 'wpc=all'
      "Afficher les #{nombre_comments} commentaires".
        in_a(href: href, class: 'small italic black').
        in_div(id: 'div_lien_autres_coms', class: 'right')
    end
    # Les commentaires de la route courante
    # Retourne une liste Array d'instance Page::Comments de ces
    # commentaires.
    #
    # Noter que pour un visiteur non administrateur, on ne prend
    # que les commentaires qui ont été validés.
    #
    # Si c'est un appel "normal", on ne prend que les vingts derniers
    # commentaires. Sinon, si l'url contient "pc=all" alors on doit
    # afficher tous les commentaires
    #
    def current_route_comments
      whereclause = "route = '#{site.current_route.route}'"
      user.admin? || whereclause += " AND SUBSTRING(options,1,1) = '1'"
      drequest = {
        where: whereclause,
        order: 'created_at DESC'
      }
      all_comments? || drequest.merge!(limit: 20)
      table.select(drequest).collect do |hcomment|
        new(hcomment)
      end
    end

    # Retourne true s'il faut afficher tous les commentaires.
    # C'est le cas lorsque l'url contient 'wpc=all'
    def all_comments?
      param(:wpc) == 'all'
    end

    def table
      @table ||= site.dbm_table(:cold, 'page_comments')
    end

  end #/<< self

end #/Comments
end #/Page
