# encoding: UTF-8
class Admin
class Taches

  # L'administrateur qui possède cette liste
  # Si défini, la todolist le concernera lui seulement.
  attr_reader :admin_id

  # = Instanciation =
  # +data+
  #   :admin_id     Le propriétaire de cette liste.
  #
  def initialize data = nil
    data ||= Hash.new
    @admin_id = data.delete(:admin_id)
  end

  def list_taches admin_current = true
    if admin_current
      liste_taches_admin_courant
    else
      liste_taches_autres_admins
    end
  end

  def taches_proches
    '[taches proches]'
  end

  def liste_taches_admin_courant
    @liste_taches_admin_courant || liste_des_taches_dispatched
    @liste_taches_admin_courant
  end

  def liste_taches_autres_admins
    @liste_taches_autres_admins || liste_des_taches_dispatched
    @liste_taches_autres_admins
  end

  # Relever toutes les tâches non achevées et les dispatcher entre
  # les tâches de l'administrateur courant et des autres administrateurs
  def liste_des_taches_dispatched
    @ladmin   = []
    @lothers  = []
    @ladmin_no_echeance   = []
    @lothers_no_echeance  = []
    # Ancienne formule : mais les appels à la table sont trop
    # en rafale. À chaque `itache.get_all`, ça fait un appel.
    # À la place, on relève toutes les données et on crée les
    # instance on leur fournissant les donnnées
    # Admin::table_taches.select(where:'state < 9',order:"echeance ASC",colonnes:[:admin_id]).each do |tid, tdata|
    #   owned_current = tdata[:admin_id] == admin_id
    #   itache = Tache::new(tid)
    #   itache.get_all
    #   litache = itache.as_li
    #   owned_current ? (@ladmin << litache) : (@lothers << litache)
    # end
    Admin.table_taches.select(where: 'state < 9', order: 'echeance ASC, state DESC').each do |tdata|
      tid = tdata[:id]
      owned_current = tdata[:admin_id] == admin_id
      itache = Tache::new(tid)
      itache.data = tdata
      litache = itache.as_li
      if owned_current
        if tdata[:echeance]
          @ladmin << litache
        else
          @ladmin_no_echeance << litache
        end
      else
        if tdata[:echeance]
          @lothers << litache
        else
          @lothers_no_echeance << litache
        end
      end
    end
    @liste_taches_admin_courant = (@ladmin + @ladmin_no_echeance).join.in_ul(class:'taches')
    @liste_taches_autres_admins = (@lothers + @lothers_no_echeance).join.in_ul(class:'taches')
  end

  # Liste {Array} des instances Tache de la liste
  def taches options = nil
    @taches = nil if options != nil
    @taches ||= begin
      options ||= {}
      where = options[:where] || 'state < 9'
      where += " AND admin_id = #{admin_id}" unless admin_id.nil?
      options.merge!(where: where)
      options.merge!(order: 'echeance ASC, state DESC')  unless options.key?(:order)
      tache_with_echeance = []
      tache_without_echeance = []
      Admin.table_taches.select(options).each do |tdata|
        t = Tache::new(tdata[:id])
        t.data= tdata
        if tdata[:echeance]
          tache_with_echeance << t
        else
          tache_without_echeance << t
        end
      end
      tache_with_echeance + tache_without_echeance
    end
  end

end #/ Taches
end #/ Admin
