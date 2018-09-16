# encoding: UTF-8
class Admin
  class << self

    def titre
      @titre ||= 'Tableau de bord'
    end

    def data_onglets
      DATA_ONGLETS
    end

    # Retourne la liste des administrateurs comme une liste
    # de valeurs pour un select de formulaire
    def as_select_values
      User::table.select(where:"options NOT LIKE '0%'", colonnes:[:pseudo]).collect do |uid, udata|
        [uid, udata[:pseudo]]
      end
    end

  end #/ << self
end #/Admin
