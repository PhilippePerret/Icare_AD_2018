# encoding: UTF-8
=begin

  Pour inclure ce module dans un objet :

      require './_objet/watcher/lib/module/include/methodes_watchers.rb'

      class <MonObjet>

        include MethodesWatchers


=end
module MethodesWatchers

  # Retourne une instance {Watchers} (pas {Watcher}) pour gérer les
  # watchers de l'objet courant (objet_id si objet normal et user_id si
  # user)
  #
  # Noter que cette liste est différente suivante qu'il s'agisse d'un
  # objet quelconque (comme un icdocument) ou d'un User. Dans le premier
  # cas, on fait une recherche sur la propriété :objet_id tandis qu'on
  # fait une recherche la propriété :user_id pour l'user.
  def watchers
    @watchers ||= begin
      site.require_objet 'watcher'
      Watchers.new(self)
    end
  end

  # La table des watchers
  #
  # Note : NE SURTOUT PAS mettre `table` car ce module est chargé dans
  # des objets qui définissent déjà cette méthode.
  def table_watchers ; @table ||= dbtable_watchers end

  # True si l'objet courant est une instance User
  # Cette donnée est importante pour savoir s'il faut affecter la propriété
  # :user_id ou :objet_id suivant les cas.
  #
  def for_user?
    @is_for_user = self.class.objet_name == 'user' if @is_for_user === nil
    @is_for_user
  end

  # Créer un watcher pour le document
  # +wdata+ Hash pour créer le watcher du document
  #         OU
  #         {String} Le processus.
  #
  # RETURN L'identifiant de la nouvelle rangée watcher
  #
  def add_watcher wdata
    wdata.instance_of?(Hash) || wdata = {processus: wdata}
    wdata = complete_data_watcher(wdata)
    has_objet_and_processus_valid?(wdata) # raise si erreur
    if has_watcher? wdata
      if OFFLINE || user.admin?
        error "ADMIN, je ré-enregistre pas deux fois le même watcher."
      end
      return nil # on s'en retourne avec NIL
    else
      wdata[:created_at] ||= Time.now.to_i
      wdata[:updated_at] ||= Time.now.to_i
      table_watchers.insert(wdata)
    end
  end
  alias :create_watcher :add_watcher

  def has_objet_and_processus_valid?(wdata)
    obj = wdata[:objet]
    pro = wdata[:processus]
    obj != nil || raise('L’objet du watcher doit impérativement être défini.')
    pro != nil || raise('Le processus du watcher doit impérativement être défini.')
    obj.instance_of?(String) || raise('L’objet du watcher doit être un String.')
    pro.instance_of?(String) || raise('Le processus du watcher doit être un String.')
    fpath = site.folder_objet + "#{obj}"
    fpath.exist? || raise("Le dossier de l'objet n'existe pas… (#{fpath})")
    fpath = fpath + "lib/_processus/#{pro}"
    fpath.exist? || raise("Le dossier du processus #{obj}/#{pro} est introuvable (`#{fpath}')…")
    true
  end

  # Détruit le ou les watchers de données +wdata+
  #
  # RETURN Le nombre d'éléments détruits
  def remove_watcher wdata
    wdata = complete_data_watcher wdata
    whereclause = wdata.collect{|k, v|"#{k} = #{v.inspect}"}.join(' AND ')
    count_init = table_watchers.count
    table_watchers.delete(where: whereclause)
    return count_init - table_watchers.count
  end
  alias :delete_watcher :remove_watcher

  # Retourne L'IDENTIFIANT DU WATCHER si le watcher existe ou NIL
  #
  # Note : on peut utiliser :created_after et :created_before pour
  # les tests.
  def has_watcher? wdata
    wdata = complete_data_watcher wdata
    created_after   = wdata.delete(:created_after)
    created_before  = wdata.delete(:created_before)
    whereclause = wdata.collect do |k, v|
      "#{k} = #{v.nil? ? 'NULL' : v.inspect}"
    end.join(' AND ')
    created_after   && whereclause += " AND created_at > #{created_after}"
    created_before  && whereclause += " AND created_at < #{created_before}"
    w = table_watchers.get(where: whereclause)
    return w.nil? ? nil : w[:id]
  end

  # Pour compléter les données de watcher avec les propriétés de
  # l'objet courant.
  def complete_data_watcher wdata
    wdata.key?(:user_id)  || wdata.merge!(user_id: (for_user? ? self.id : user.id))
    return wdata
  end

  # ---------------------------------------------------------------------
  #   Class <Objet>::Watchers
  #   -----------------------
  #   Pour la gestion des watchers de l'objet
  #
  class Watchers
    attr_reader :owner
    def initialize owner
      @owner = owner
    end

    # Retourne les watchers comme une liste HTML
    def as_ul options = nil
      list.collect do |watcher|
        # Attention, watcher.as_li peut retourner NIL, lorsque par exemple
        # il n'y a pas de notification pour le watcher donné ou qu'il n'est
        # pas encore déclenché.
        watcher.as_li(options)
      end.compact.join.in_ul(class: 'notifications', id: "watchers-#{owner.class.objet_name}-#{owner.id}")
    end

    # La liste dépend du fait que :
    #   1.  l'objet est un User ou un objet quelconque (document, etc.)
    #   2.  Si c'est un User, s'il s'agit de l'administrateur ou d'un
    #       user quelconque.
    #
    # Noter qu'on ne gère pas ici le triggered donc qu'il faut le filtrer
    # dans une méthode ultérieure.
    def list
      @list ||= begin
        table.select(list_request).collect do |hwatcher|
          SiteHtml::Watcher.new(hwatcher[:id], hwatcher)
        end
      end
    end

    def list_request
      @list_request ||= begin
        if for_users?
          if owner.manitou?
            {}
          else
            { where: {user_id: owner.id} }
          end
        else
          { where: {objet_id: owner.id} }
        end
      end
    end

    # Retourne true si ce sont les watchers pour un User
    def for_users?
      @is_for_user = owner.class.objet_name == 'user' if @is_for_user === nil
      @is_for_user
    end

    def remove
      table.delete(list_request)
    end

    def table ; @table ||= site.dbm_table(:hot, 'watchers') end
  end #/<Objet>::Watchers

end #/MethodesWatchers
