# encoding: UTF-8
class IcModule

  extend MethodesMainObjet

  class << self


    # Méthode qui crée le nouvel IcModule pour l'icarien
    # +owner+ pour le module d'apprentissage d'identifiant
    # absolu +absmodule_id
    # Cette méthode sert à plusieurs endroits, notamment à
    # la création normale du module pour l'icarien ou pour
    # un changement de module dans les opérations
    #
    # @retourne la nouvelle instance {IcModule} créée
    # 
    def create_icmodule_for owner, absmodule_id
      icmodule_id = table.insert(data_new_module(owner, absmodule_id))
      new(icmodule_id)
    end
    # Retourne le Hash des données pour le nouveau module
    def data_new_module owner, absmodule_id
      {
        user_id:        owner.id,
        abs_module_id:  absmodule_id,
        next_paiement:  nil,
        options:        '0',
        created_at:     Time.now.to_i,
        updated_at:     Time.now.to_i
      }
    end


    def table ; @table ||= site.dbm_table(:modules, 'icmodules') end

  end #/<<self

end #/IcModule
