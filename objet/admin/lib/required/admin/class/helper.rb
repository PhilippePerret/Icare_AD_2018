# encoding: UTF-8
class Admin
  class << self

    def titre_h1 sous_titre = nil
      t = "Tableau de bord".in_h1
      t << onglets
      t << sous_titre.in_h2 unless sous_titre.nil?
      t
    end

    def onglets
      DATA_ONGLETS.collect do |route, titre|
        titre.in_a(href:route).in_li
      end.join.in_ul(class:'onglets')
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
