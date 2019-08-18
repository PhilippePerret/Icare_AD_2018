# encoding: UTF-8
class SiteHtml
class Actualite

  def user_id     ; @user_id    ||= get(:user_id)     end
  def message     ; @message    ||= get(:message)     end
  def data        ; @data       ||= get(:data)        end
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

end #/Actualite
end #/SiteHtml
