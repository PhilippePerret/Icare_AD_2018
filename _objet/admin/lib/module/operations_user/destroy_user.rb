# encoding: UTF-8

class Admin
  class Users
    class << self

      # Identifiant de l'icarien à détruire
      # Soit on le choisit dans le menu (par exemple s'il n'a pas encore
      # été détruit), soit on indique son ID dans le champ court
      # Le champ court a toujours la priorité
      def user_id
        @user_id ||= short_value.to_i
      end

      def user
        @user ||= User.get(user_id)
      end

      # Pour savoir si une destruction a été opérée, d'au moins un élément
      def une_destruction_operee
        @une_destruction_operee
      end

      # Outil pour détruire complètement un user
      def exec_destroy_user

        # Si on est en offline et que le champ short_value n'est pas défini,
        # il faut créer un nouvel utilisateur
        if OFFLINE && short_value.nil?
          user_sans_paiement
        end

        # # Pour voir les discussions qui sont retournées
        # # ---------------------------------------------
        # t = site.dbm_table(:users, 'frigo_discussions')
        # discussion_ids =
        #   t.
        #     select(where: ('(user_id = %i OR owner_id = %i)' % [user_id, user_id]), columns: [:id]).
        #     collect { |h| h[:id] }
        # debug "---- discussion_ids : #{discussion_ids.inspect}"
        # return


        destroyable? || return # en fait, la méthode raisera

        @suivi << 'ID de l’icarien à détruire : #%i' % user_id

        # Le détruire dans la base des Users
        destroy_user_in_db
        # Destruction de ses watchers éventuels
        destroy_user_watchers
        # Destruction des actualité de l'user
        destroy_user_actualites
        # Destruction des modules et étapes
        destroy_user_modules_et_etapes
        # Destruction des tickets de l'user
        destroy_user_tickets
        # Destruction des autres petites choses
        destroy_user_other_things

        if @une_destruction_operee
          @suivi << "\n\n= DESTRUCTION DE L'ICARIEN OPÉRÉE AVEC SUCCÈS ="
        else
          add_error 'Bizarrement, rien n’a été détruit. Est-ce le bon ID ?'
        end

      rescue Exception => e
        add_error e.message
      end


      def destroy_user_in_db
        @suivi << begin
          if delete_in_db(:users, 'users') > 0
            '  = Destruction de l’icarien dans la base de données'
          else
            '  = User #%i inconnu dans la base de données (peut être normal)' % user_id
          end
        end
      end

      def destroy_user_watchers
        nombre = delete_in_db(:hot, 'watchers')
        @suivi << '  = Destruction des watchers de l’user (%i)' % nombre
      end

      def destroy_user_actualites
        nombre = delete_in_db(:hot, 'actualites')
        @suivi << '  = Destruction des actualités de l’user (%i)' % nombre
      end

      def destroy_user_modules_et_etapes
        nombre = delete_in_db(:modules, 'icmodules')
        msg = ["#{nombre} ic-module(s)"]
        nombre = delete_in_db(:modules, 'icetapes')
        msg << "#{nombre} ic-etape(s)"
        nombre = delete_in_db(:modules, 'icdocuments')
        msg << "#{nombre} ic-documents(s)"
        @suivi << '  = Destruction des modules et étapes de l’user (%s)' % [msg.join(', ')]
      end

      def destroy_user_tickets
        nombre = delete_in_db(:hot, 'tickets')
        @suivi << '  = Destruction des tickets éventuels de l’user (%i)' % nombre
      end

      def destroy_user_other_things
        nombre = Hash.new

        # Témoignages
        if nombre_in_db(:cold, 'temoignages') > 0
          nb = delete_in_db(:cold, 'temoignages')
          @suivi << '  = Nombre de témoignages détruits : %i' % nb
        end

        # Frigo
        if nombre_in_db(:users, 'frigo_discussions') > 0
          t = site.dbm_table(:users, 'frigo_discussions')
          discussion_ids =
            t.select(where: ('(user_id = %i OR owner_id = %i)' % [user_id, user_id]), columns: [:id]).
              collect {|h| h[:id]}

          if discussion_ids.count > 0
            t.delete(where: ('user_id = %i OR owner_id = %i' % [user_id, user_id]))
            @une_destruction_operee = true # pour savoir si quelque chose a été détruit
          end
          t = site.dbm_table(:users, 'frigo_messages')
          nb = t.count(where: 'discussion_id IN (%s)' % [discussion_ids.join(',')])
          if nb > 0
            t.delete(where: 'discussion_id IN (%s)' % [discussion_ids.join(',')])
            @une_destruction_operee = true # pour savoir si quelque chose a été détruit
          end
          @suivi << "  = Nombre messages frigo détruits : %i" % nb

          @suivi << '  = Nombre discussions frigo détruites : %i' % [discussion_ids.count]
        end

      end

      # Retourne TRUE si l'user choisi est destructible
      def destroyable?

        if short_value.to_s.start_with?('S')
          @short_value  = short_value[1..-1].to_i
          @user_id      = @short_value
        else
          short_value.to_s == icarien_id.to_s ||
            raise('Pour détruire un icarien, il faut que l’ID dans le champ court corresponde à l’icarien(ne) choisi(e) dans le menu. Si l’icarien ne se trouve pas dans le menu, mettre un <q>S » devant l’identifiant dans le champ court.')
        end

        # Ne surtout pas le mettre ci-dessus, `user` serait toujours le même
        not_destroyable = '%s ne peut être détruit%s.' % [user.f_elle, user.f_e]

        user_id > 0 ||
          raise('Il faut choisir un(e) icarien(ne) (soit dans le menu soit en indiquant son ID dans le champ court).')

        # Un administrateur ne peut être détruit
        user_id > 3 ||
          raise('%s administre l’atelier, %s' % ["#{user.pseudo} (##{user_id})", not_destroyable])
        # Un icarien qui possède un paiement ne peut être détruit
        nombre_paiements = nombre_in_db(:users, 'paiements')
        nombre_paiements == 0 ||
          raise('Cet%s icarien%s possède un paiement, %s' % [user.f_te, user.f_ne, not_destroyable])

      end

      # Nombre d'éléments pour l'user dans la table base:table
      def nombre_in_db base, table
        table_in_db(base,table).count(where: wherefor(base, table) )
      end
      # Destruction des éléments pour l'user dans la table base:table
      # Retourne le nombre d'éléments détruits
      def delete_in_db base, table
        nombre = nombre_in_db(base, table)
        if nombre > 0
          table_in_db(base,table).delete(where: wherefor(base, table))
          @une_destruction_operee = true # pour savoir si quelque chose a été détruit
        end
        return nombre
      end

      def wherefor(base, table)
        if base == :users && table == 'users'
          {id: user_id}
        else
          {user_id: user_id}
        end
      end

      def table_in_db base, table
        site.dbm_table(base, table)
      end



      # ---------------------------------------------------------------------
      # MÉTHODES UTILITARIES POUR CRÉER L'OPÉRATION

      def user_sans_paiement

        phil = User.get(1)

        now = Time.now.to_i
        hier = now - 1.day
        avanthier = now - 2.days
        ilyadixjours = now - 10.days

        tuser = table_in_db(:users, 'users')
        data_user = {
          pseudo: 'BadGirl', sexe: 'F', mail: 'sonmail@bad.com',
          cpassword: 'unmotdepassecryptedpourrien', salt: 'sonsel',
          options: '0'*16, created_at: ilyadixjours
          }
        if tuser.get(where: {pseudo: data_user[:pseudo]})
          @suivi << 'BadGirl existe déjà pour l’opération, je le la recrée pas.'
          return
        end

        @suivi << 'Création d’un user pour l’opération'
        uid = tuser.insert(data_user)
        @suivi << 'Icarien ID #%i créé' % uid

        # On lui crée un module
        tmodules = table_in_db(:modules, 'icmodules')
        data_module = {
          user_id: uid, abs_module_id: 8, project_name: 'Projet de badgirl',
          paiements: nil, started_at: avanthier, options: '10000000',
          icetapes: "", icetape_id: nil
        }
        icmodule_id = tmodules.insert(data_module)
        @suivi << 'Création du module d’apprentissage #%i' % icmodule_id

        # On lui crée une étape
        t = table_in_db(:modules, 'icetapes')
        data_etape = {
          user_id: uid, abs_etape_id: 135, icmodule_id: icmodule_id,
          numero: 1, started_at: avanthier, expected_end: now,
          status: 1
        }
        icetape_id = t.insert(data_etape)
        @suivi << 'Création de l’étape #%i' % icetape_id

        # On met cette étape dans le module
        tmodules.update(icmodule_id, {icetape_id: icetape_id})

        # On lui crée des documents
        t = table_in_db(:modules, 'icdocuments')
        ids = Array.new
        [
          {user_id: uid, abs_module_id: data_module[:abs_module_id], abs_etape_id: data_etape[:abs_etape_id],
          icmodule_id: icmodule_id, icetape_id: icetape_id, doc_affixe: 'le_doc', original_name: 'Le doc',
          time_original: ilyadixjours, created_at: ilyadixjours},
          {user_id: uid, abs_module_id: data_module[:abs_module_id], abs_etape_id: data_etape[:abs_etape_id],
          icmodule_id: icmodule_id, icetape_id: icetape_id, doc_affixe: 'le_doc_2', original_name: 'Le doc 2',
          time_original: ilyadixjours, created_at: ilyadixjours},
          {user_id: uid, abs_module_id: data_module[:abs_module_id], abs_etape_id: data_etape[:abs_etape_id],
          icmodule_id: icmodule_id, icetape_id: icetape_id, doc_affixe: 'le_doc_3', original_name: 'Le doc 3',
          time_original: ilyadixjours, created_at: ilyadixjours},
        ].each do |data_document|
          ids << t.insert(data_document)
        end
        @suivi << 'Création de %i documents : %s' % [ids.count, ids.collect{|i| "##{i}"}.join(', ')]

        # On lui crée 2 watchers
        t = table_in_db(:hot, 'watchers')
        [
          {user_id: uid, objet: 'ic_module', objet_id: icmodule_id, processus: 'paiement', created_at: avanthier},
          {user_id: uid, objet: 'ic_etape', objet_id: icetape_id, processus: 'send_work', created_at: hier}
        ].each do |data_watcher|
          wid = t.insert(data_watcher)
          @suivi << 'Création du watcher #%i' % wid
        end

        # On lui crée trois tickets
        t = table_in_db(:hot, 'tickets')
        [
          {user_id: uid, id: '02a76053759cc5c8d363e346f7621a81', code: 'User.get(1)', created_at: ilyadixjours},
          {user_id: uid, id: '02a76053759cc5c8d363e346f7621a82', code: 'User.get(1)', created_at: avanthier}
        ].each do |data_ticket|
          t.insert(data_ticket)
          # Rappel : pas d'id calculé pour les tickets, ils sont fournis
        end
        @suivi << 'Création de %i ticket(s)' % [ids.count]

        # On lui crée des actualités
        t = table_in_db(:hot, 'actualites')
        [
          {user_id: uid, message: 'Un message de bonne actualité.', status: 2, created_at: avanthier},
          {user_id: uid, message: 'Un autre message de bonne actualité.', status: 1, created_at: hier}
        ].each do |data_actu|
          id = t.insert(data_actu)
          @suivi << 'Création de l’actualité #%i' % id
        end

        # On lui crée un témoignage
        t = table_in_db(:cold, 'temoignages')
        data_temoignage = {
          user_id: uid,
          user_pseudo: data_user[:pseudo],
          content: 'Le témoignage de la bad girl en essai',
          confirmed: 1,
          updated_at: now,
          created_at: now
        }
        id = t.insert(data_temoignage)
        @suivi << 'Création du témoignage #%i' % id

        # On lui crée des messages frigo
        t = table_in_db(:users, 'frigo_discussions')
        data_dis1 = {owner_id: 1, user_id: uid, user_mail: phil.mail, user_pseudo: 'Phil',
          options: '1', created_at: ilyadixjours, updated_at: ilyadixjours}
        dis1_id = t.insert(data_dis1)
        @suivi << 'Il participe à la discussion #%i avec Phil' % dis1_id

        data_dis2 = {owner_id: uid, user_id: 1, user_mail: data_user[:mail], user_pseudo: data_user[:pseudo],
          options: '1', created_at: ilyadixjours, updated_at: ilyadixjours}
        dis2_id = t.insert(data_dis2)
        @suivi << 'Il a lancé la discussion #%i' % [dis2_id]


        t = table_in_db(:users, 'frigo_messages')
        ids = Array.new
        [
          {discussion_id: dis1_id, auteur_ref: 'i', content: 'Le premier message', created_at: ilyadixjours, updated_at: ilyadixjours},
          {discussion_id: dis2_id, auteur_ref: 'o', content: 'Le deuxième message', created_at: ilyadixjours, updated_at: ilyadixjours},
          {discussion_id: dis2_id, auteur_ref: 'o', content: 'La réponse au deuxième message', created_at: avanthier, updated_at: avanthier},
          {discussion_id: dis1_id, auteur_ref: 'i', content: 'La réponse au premier message', created_at: hier, updated_at: hier}
        ].each do |data_message|
          ids << t.insert(data_message)
        end
        @suivi << 'Ajout de %i messages de discussion : %s' % [ids.count, ids.collect{|i|"##{i}"}.join(', ')]

        @suivi << "\n= USER ##{uid} CRÉÉ AVEC SUCCÈS. PSEUDO : #{data_user[:pseudo]} ="
      end
      #/user_sans_paiement

    end #/self
  end #/Users
end #/Admin
