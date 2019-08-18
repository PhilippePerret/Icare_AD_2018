# encoding: UTF-8
=begin

  Module permettant d'enregistrer un commentaire de page puis
  retournant à ladite page.

=end
class Page
  class Comments
    class << self

      # = main =
      #
      # Méthode principale appelée pour créer le nouveau
      # commentaire après vérifications diverses.
      #
      def create_comment
        new_com = new(data_new_comment)
        # On corrige le commentaire avant de l'enregistrer
        new_com.formate_comment
        if new_com.create
          flash "Merci #{user.pseudo} pour votre commentaire. Il sera validé très prochainement."
          # On envoie le mail d'information à l'administration
          new_com.avertissement_administration
          # Pour forcer le recalcul, au cas où
          reset
          # Pour empêcher d'afficher le formulaire
          @display_formulaire = false
        else
          error "Impossible d’enregistrer ce commentaire."
        end
      rescue Exception => e
        debug e
        error "Malheureusement, un problème est survenu : #{e.message}"
      end

      def data_new_comment
        @data_new_comment ||= begin
          dcom = param(:pcomments)
          {
            user_id:      user.id,
            pseudo:       user.pseudo,
            route:        dcom[:route].nil_if_empty,
            comment:      comment_purified(dcom),
            votes_up:     0,
            votes_down:   0,
            options:      '0'*8,
            created_at:   Time.now.to_i,
            updated_at:   Time.now.to_i
          }

        end
      end
      # Le commentaire purifié, pour retirer toutes les
      # intrusions possibles et formaté convenablement.
      #
      def comment_purified dcom
        cp = dcom[:comment].nil_if_empty
        cp != nil || (return nil) # sera traité plus tard
        return cp
      end
    end #/<<self

    # ---------------------------------------------------------------------
    #   Instance
    # ---------------------------------------------------------------------


    def create
      check_values || (return false)
      @id = self.class.table.insert(data)
      return true
    end

    # Vérification des valeurs
    #
    # En plus des vérifications normales, on s'assure que l'user
    # n'a pas laissé un message dans l'heure précédente sur cette
    # page, ce qui n'est possible que pour un administrateur
    #
    def check_values
      comment != nil          || raise('Il faut impérativement fournir un commentaire valide !')
      route != nil            || raise('La route doit être définie.')
      user_id != nil          || raise('Votre identifiant devrait être défini…')
      ucheck = User.new(user_id)
      ucheck.exist?           || raise('Cet identifiant ne correspond à aucun utilisateur…')
      pseudo != nil           || raise('Le pseudo devrait être défini…')
      ucheck.pseudo == pseudo || raise('Le pseudo ne correspond pas… Bizarre, bizarre…')

      unless user.admin?
        whereclause = ["user_id = #{user_id}", "route = '#{route}'", "created_at > #{Time.now.to_i - 1.hour}"].join(' AND ')
        dreq = {where: whereclause}
        table.count(dreq) == 0 || raise('Vous devez laisser une heure entre deux commentaires sur la même page.')
      end
    rescue Exception => e
      error e.message
      false
    else
      true # pour poursuivre
    end

    # Le ticket qui permettra à l'administrateur
    # de valider directement le commentaire.
    def ticket
      @ticket ||= begin
        ticket_code = "User.autologin_admin(:phil);Page::Comments.valider_comment(#{id});User.delogin_admin"
        app.create_ticket(nil, ticket_code)
      end
    end

    # Envoi d'un mail pour informer qu'il faut valider le nouveau
    # commentaire
    def avertissement_administration
      data_mail = {
        subject:        'Dépôt d’un nouveau commentaire',
        message:        message_admin,
        # force_offline:  true, # seulement pendant test, au besoin
        formated:       true
      }
      site.send_mail_to_admin(data_mail)
    rescue Exception => e
      debug e
      # Ne rien faire de plus pour le poment
    end

    def message_admin
      <<-MAIL
<p>Phil</p>
<p>Je t'informe qu'un nouveau commentaire a été déposé sur la page :</p>
<p><a href="#{site.distant_url}/#{route}">#{route}</a></p>
<p>Ce commentaire est à valider pour être publié.</p>
<p>Pour valider directement ce commentaire :</p>
<p>#{ticket.link('Valider ce commentaire')}</p>
<p>Ou tu peux rejoindre la <a href="page_comments/list?in=site">section de validation des commentaires</a></p>
<p>Commentaire ##{id}:</p>
<hr />
<p>#{comment}</p>
<hr />
<p>Auteur : #{pseudo} (user ##{user_id})</p>
      MAIL
    end

  end #/Comments
end #/Page

Page::Comments.create_comment
redirect_to :last_route
