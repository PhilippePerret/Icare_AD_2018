# encoding: UTF-8
=begin

Class User
----------
Instance

=end
class User

  include MethodesMySQL

  # Identifiant de l'user dans la table
  attr_reader :id

  # Instanciation, à l'aide de l'ID optionnel
  def initialize uid = nil
    @id = uid
    # Initialisation de propriétés volatiles utiles
    @preferences = Hash.new
  end

  def bind; binding() end

  # Pseudo de l'user
  # ----------------
  # Même lorsqu'il n'est pas identifié, il a un pseudo
  def pseudo
    @pseudo ||= begin
      identified? ? get(:pseudo) : 'Ernest'
    end
  end
  def mail        ; @mail       ||= get(:mail)          end
  def cpassword   ; @cpassword  ||= get(:cpassword)     end
  def sexe        ; @sexe       ||= get(:sexe)          end
  def patronyme   ; @patronyme  ||= get(:patronyme)     end
  def options     ; @options    ||= get(:options) || '' end
  def session_id  ; @session_id ||= get(:session_id)    end
  def created_at  ; @created_at ||= get(:created_at)    end
  def updated_at  ; @updated_at ||= get(:updated_at)    end

  # Identifiant du module d'apprentissage
  def icmodule_id ;   @icmodule_id  ||= get(:icmodule_id)  end

  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------
  def ip
    @ip ||= ENV["REMOTE_ADDR"] || ENV['HTTP_CLIENT_IP'] || ENV["HTTP_X_FORWARDED_FOR"]
  end

end
