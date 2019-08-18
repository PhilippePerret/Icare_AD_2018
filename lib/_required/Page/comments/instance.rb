# encoding: UTF-8
class Page
  class Comments

    include MethodesMySQL

    # Toutes les données envoyées
    # Cette donnée est importante car elle sert notamment à la
    # création du commentaire
    attr_reader :data

    attr_reader :id, :pseudo, :user_id
    attr_reader :route, :comment, :date
    attr_reader :votes_up, :votes_down
    attr_reader :created_at, :updated_at
    # Les propriétés qui peuvent être appelées sans charger toutes
    # les données et en instanciant avec seulement l'identifiant du
    # commentaire (validation par exemple)
    def options   ; @options ||= get(:options)  end

    # On peut soit instancier le commentaire avec toutes ses
    # données, soit avec son identifiant Integer
    def initialize hdata
      case hdata
      when Hash
        @data = hdata
        hdata.each{|k, v| instance_variable_set("@#{k}", v)}
      when Integer
        @id = hdata
      end
    end

    def valided?
      @is_valided ||= options[0].to_i == 1
    end

    # = main =
    #
    # Code HTML du commentaire dans sa liste
    #
    def as_li options = nil
      options ||= Hash.new
      (
        div_route(options[:show_route]) +
        div_infos +
        div_commentaire +
        div_boutons
      ).in_li(id: li_id, class: 'pcomment')
    end
    def li_id; @li_id ||= "li_pcomment-#{id}" end


    def div_route showit
      showit || (return '')
      "⦿ Page #{route}".in_a(href: route, target: :new, class: 'bold').in_div(class: 'cp_route')
    end
    def div_infos
      (
      span_date +
      span_numero +
      span_auteur
      ).in_div(class: 'infos')
    end

    # Div contenant le commentaire formaté
    #
    # Noter que le commentaire a été formaté à l'enregistrement
    # (pour ne faire qu'une seule fois l'opération et vérifier
    # le texte)
    #
    def div_commentaire
      comment.in_div(class: 'comment')
    end

    def div_boutons
      bs = String.new
      bs << bouton_vote_up
      bs << bouton_vote_down
      if user.admin?
        bs << bouton_detruire
        valided? || bs << bouton_valider
      end
      bs.in_div(class: 'boutons btns')
    end


    def span_date
      created_at.as_human_date(true, true, nil, 'à').in_span(class: 'date')
    end
    def span_auteur
      pseudo.in_span(class: 'auteur')
    end
    def span_numero
      user.admin? || (return '')
      "##{id}".in_span(class: 'id')
    end

    def bouton_vote_up
      (
        "+ #{votes_up.to_s.in_span(class: 'upvotes')} ".in_span +
        '+1'.in_a(onclick:"PComments.upvote(#{id})", class: 'btn tiny discret')
      )
    end
    def bouton_vote_down
      (
        '-1'.in_a(onclick:"PComments.downvote(#{id})", class: 'btn tiny discret') +
        "- #{votes_down.to_s.in_span(class: 'downvotes')}".in_span
      )
    end
    def bouton_detruire
      'détruire'.in_a(class: 'warning tiny btn', href: "page_comments/#{id}/list?in=site&action=destroy")
    end
    def bouton_valider
      'valider'.in_a(class: 'btn tiny', href: "page_comments/#{id}/list?in=site&action=valider")
    end

    def table
      @table ||= self.class.table
    end

  end #/Comments
end #/Page
