# encoding: UTF-8
class Frigo

  # Retourne la discussion à écrire dans la page
  def current_discussion
    @current_discussion ||= begin
      hdis = discussion_with_current
      hdis != nil || raise('Il devrait exister une discussion, ici…')
      Frigo::Discussion.new(hdis[:id])
    end
  end
  # /current_discussion

  def current_discussion= dis
    @current_discussion = dis
  end


  # Créer une discussion sur le frigo
  #
  # Retourne le texte à écrire dans la fenêtre
  def create_discussion

    # Si le frigo n'existe pas, il faut le créer
    self.exist? || begin
      self.create
      if self.exist?
        debug "  = Frigo créé avec succès"
      else
        raise 'Le frigo n’a pas pu être créé…'
      end
    end

    # On crée la discussion dans ce frigo
    dis = Frigo::Discussion.new
    dis.create
    dis.display
  end
  # /create_discussion

  # Toutes les discussions. C'est un objet pluriel
  def discussions
    @discussions ||= Discussions.new(self.owner)
  end

  # ---------------------------------------------------------------------
  #
  #   DISCUSSIONS COMME UN ENSEMBLE
  #
  # ---------------------------------------------------------------------
  class Discussions

    # Propriétaire des discussions
    attr_reader :owner

    def initialize owner
      @owner = owner
    end

    # Affichage de TOUTES les discussions du propriétaire
    def display
      list.collect do |dis|
        frigo.current_discussion = dis
        dis.display
      end.join.in_div(class: 'discussions')
    end

    def table_des_matieres
      (
        'Interlocuteurs'.in_h4 +
        list.collect do |dis|
          (
            (
              'masquer'.in_a(id: "btn_toggle_discussion-#{dis.id}", onclick: "$.proxy(Frigo,'toggle_mask',#{dis.id})()")
            ).in_div(class: 'fright') +
            dis.user_pseudo.in_a(href: "bureau/#{frigo.owner_id}/frigo#discussion-#{dis.id}").in_span(id: "pseudo-#{dis.id}", class: 'pseudo')
          ).in_div
        end.join.in_div(id: 'interlocuteurs')
      ).in_div(id: 'div_interlocuteurs')
    end

    # Note : on ne prend que les discussions qui ont des messages
    #
    def list
      @list ||= begin
        drequest = {
          where: {owner_id: owner.id},
          colonnes: []
        }
        dbtable_frigo_discussions.select(drequest).collect do |hdis|
          dbtable_frigo_messages.count(where:{discussion_id: hdis[:id]}) > 0 || next
          Frigo::Discussion.new(hdis[:id])
        end.compact
      end
    end

  end#/Discussions
end#/Frigo
