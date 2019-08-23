# encoding: UTF-8
class SiteHtml
class Actualite
  class << self

    # = main =
    #
    # Construction ou reconstruction du fichier pour l'accueil
    # contenant les dernières actualités
    #
    # RETURN Le code du listing, pour inscription dans la page
    #
    def _build_file_last_actualites
      rf = site.file_last_actualites
      rf.remove if rf.exist?
      rf.write code_last_actualites
      code_last_actualites
    end

    # Le code HTML du listing des activités (ul#last_actualites)
    def code_last_actualites
      last_actualites.collect do |actu|
        actu.as_li_for_home #cf. ci-dessous
      end.join.in_ul(id: 'last_actualites')
    end

    def last_actualites
      @last_actualites ||= begin
        drequest = { order: 'created_at DESC', limit: 15 }
        table.select(drequest).collect do |hactu|
          new(hactu[:id], hactu)
        end
      end
    end

  end #/<<self

  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour l'instance
  # ---------------------------------------------------------------------

  # Retourne le code HTML pour l'affichage de l'actualité
  def as_li_for_home
    (
      span_date   +
      span_message
    ).in_li(class: 'actu', id: "actu-#{id}")
  end
  def span_date
    created_at.to_i.as_human_date(false, true).in_span(class: 'date')
  end
  def span_message
    message.in_span(class:'message')
  end

end #/Actualite
end #/SiteHtml
