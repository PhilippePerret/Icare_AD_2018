# encoding: UTF-8
class SiteHtml
class Actualite

  extend MethodesMainObjet

  class << self

    # Méthode pour créer une nouvelle actualité
    # +dactu+
    #         SOIT Hash des données de l'actu, qui doivent au minimum
    #         contenir
    #           :message      Le message de l'actualité.
    #         Mais peut contenir aussi :
    #           :user_id      L'user concerné (le courant si non fourni)
    #           :data         {Hash} Les données à conserver
    #
    #         SOIT Symbol identifiant une opération type.
    #              Par exemple, :signup pour une nouvelle inscription.
    #
    # La méthode détruit également le fichier ./_objet/site/actualites.html
    # pour forcer sa reconstruction.
    #
    # RETURN L'identifiant de la nouvelle données créée
    def create dactu
      dactu.instance_of?(Hash) || dactu = data_actualite_from_symbol(dactu)
      dactu[:user_id] ||= user.id
      dactu[:status]  ||= 1
      dactu[:data].nil? || begin
        case dactu[:data]
        when String then nil # déjà jsonné
        else dactu[:data] = dactu[:data].to_json
        end
      end
      dactu.merge!(created_at: Time.now.to_i, updated_at: Time.now.to_i)
      site.file_last_actualites.remove if site.file_last_actualites.exist?
      return table.insert(dactu)
    end

    # Retourne les données de l'actualité à enregistrer en fonction
    # du symbol +sym+ (qui peut être par exemple :signup pour l'inscription)
    def data_actualite_from_symbol sym
      case sym
      when :signup
        dactu = {message: "Inscription de <strong>#{user.pseudo}</strong>."}
      end
      # Dans tous les cas, une actualité "symbolique" concerne l'user
      # courant
      dactu.merge!(user_id: user.id)
    end

    # Méthode qui reconstruit le fichiers des derniers actualités
    def build_file_last_actualites
      SiteHtml::Actualites.require_module 'last_actualites'
    end

    def table; @table ||= site.dbm_table(:hot, 'actualites') end

  end #/<<self
end #/Actualite
end #/SiteHtml
