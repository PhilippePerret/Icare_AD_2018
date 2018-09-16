# encoding: UTF-8
=begin

  SiteHtml::Updates Méthodes d'helper

=end
class SiteHtml
class Updates

  # Nombre maximum d'updates qu'il faut afficher dans
  # la page.
  NOMBRE_MAX_UPDATES_PER_PAGE = 50

  class << self

    def as_ul args = nil
      args ||= {}
      args[:from] ||= 0
      args[:to]   ||= args[:from] + NOMBRE_MAX_UPDATES_PER_PAGE
      data_request = {
        order:    'created_at DESC',
        limit:    args[:to] - args[:from],
        offset:   args[:from] - 1
      }
      table.select(data_request).collect do |udata|
        Update.new(udata).as_li
      end.join('').in_ul(class: 'tdm', id: 'updates')
    end

  end #/<< self

  # ---------------------------------------------------------------------
  #   SiteHtml::Updates::Update
  #   -------------------------
  #   Méthodes d'helper qui permet de construire la liste des
  #   updates.
  # ---------------------------------------------------------------------
  class Update
    def as_li
      (
        link_to_page  +
        human_date    +
        "##{id}- #{message}".in_span(class: 'm')
      ).in_li(class: class_li)
    end

    # Retourne la classe de la ligne LI de l'update
    # C'est 'update' par défaut, mais on ajoute la
    # class 'unread' si l'user est identifié et que c'est une
    # actualisation qu'il n'a pas encore vu
    def class_li
      css = ['update']
      if user.identified?
        user.last_connexion > created_at || ( css << 'unread' )
      end
      css << 'bold' if importante?
      css.join(' ')
    end
    def human_date
      Time.at(created_at).strftime('%d %m %Y - %H:%M').in_span(class: 'd')
    end
    def link_to_page
      route || (return "")
      "-> voir".in_a(href: route, target: '_blank').in_span(class: 'lk')
    end

  end

end #/Updates
end #/SiteHtml
