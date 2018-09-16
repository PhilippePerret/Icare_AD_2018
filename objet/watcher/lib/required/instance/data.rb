# encoding: UTF-8
class SiteHtml
class Watcher

  # ---------------------------------------------------------------------
  #   Data dans la base
  # ---------------------------------------------------------------------
  attr_reader :id, :data_instanciation
  def user_id     ; @user_id    ||= get(:user_id)     end
  def objet       ; @objet      ||= get(:objet)       end
  def objet_id    ; @objet_id   ||= get(:objet_id)    end
  def processus   ; @processus  ||= get(:processus)   end
  def triggered   ; @triggered  ||= get(:triggered)   end
  def data        ; @data       ||= get(:data)        end
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def owner; @owner ||= User.new(user_id) end
  alias :icarien :owner

  # L'objet visé par le watcher, défini par `objet` et `objet_id`
  # Mais noter que parfois le nom de l'objet ne correspond pas à
  # la classe. Par exemple, le nom de l'objet 'ic_document' répond
  # à la classe `IcModule::IcEtape::IcDocument`. Il faut donc définir
  # ici les objets spéciaux
  def instance_objet
    @instance_objet ||= begin
      classe =
        case objet
        when 'ic_document'  then IcModule::IcEtape::IcDocument
        when 'ic_etape'     then IcModule::IcEtape
        when 'abs_etape'    then AbsModule::AbsEtape
        else
          Object.const_get(objet.camelize)
        end
      classe.new(objet_id)
    end
  end
end#/Watcher
end#/SiteHtml
