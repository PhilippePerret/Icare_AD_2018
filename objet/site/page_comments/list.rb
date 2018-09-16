# encoding: UTF-8
=begin

  Module permettant de lister tous les commentaires de page
  Notamment pour les valider

=end
class Page
  class Comments
    class << self

      # Code UL de la liste des commentaires non validés
      def ul_comments_non_valided
        user.admin? || (return '') # au cas où
        table.select(where: 'SUBSTRING(options,1,1) = "0"').collect do |hcom|
          new(hcom).as_li
        end.join('').in_ul(id: 'ul_comments_non_valided', class: 'ul_page_comments')
      end
      def nombre_comments_non_valided
        table.count(where: 'SUBSTRING(options,1,1) = "0"')
      end
      def nombre_comments_valided
        table.count(where: 'SUBSTRING(options,1,1) = "1"')
      end

      def ul_comments_valided args = nil
        args ||= Hash.new
        args[:from] ||= 0
        args[:to]   ||= 50
        args[:from] = args[:from].to_i
        args[:to]   = args[:to].to_i
        nombre =
          if args[:to]
            args[:to] - args[:from]
          else
            args[:nombre].to_i
          end
        # debug "Nombre : #{nombre}"
        current_route = nil
        boutons_navigation(:top, args[:from], nombre_commentaires) +
        table.select(where: 'SUBSTRING(options,1,1) = "1"', offset: args[:from], limit: nombre, order: 'route').collect do |hcom|
          same_route = current_route == hcom[:route]
          same_route || current_route = hcom[:route]
          new(hcom).as_li(show_route: !same_route) # => collect
        end.join('').in_ul(id: 'ul_comments_valided', class: 'ul_page_comments') +
        boutons_navigation(:bottom, args[:from], nombre_commentaires)
      end

      def boutons_navigation where = :bottom, from, nombre_max
        (bouton_backward(from) + bouton_forward(from, nombre_max)).in_nav(class: "buttons #{where}")
      end

      def bouton_backward from
        href = "page_comments/list?in=site&from_comment=#{from - 50}&to_comment=#{from - 1}"
        lien.bouton_backward( href: href, visible: from > 0 )
      end
      def bouton_forward from, nombre_max
        href = "page_comments/list?in=site&from_comment=#{from + 50}&to_comment=#{from + 99}"
        lien.bouton_forward( href: href, visible: (from + 50) < nombre_max)
      end


      def nombre_commentaires
        @nombre_commentaires ||= begin
          if app.session['nombre_total_page_comments'].nil?
            debug "Je compte le nombre de commantaires"
            app.session['nombre_total_page_comments'] = table.count(where: 'SUBSTRING(options,1,1) = "1"')
          else
            debug "Je reprends le nombre de commentaires dans session"
            app.session['nombre_total_page_comments']
          end
        end
      end
    end #/<< self
  end #/Comments
end #/Page
