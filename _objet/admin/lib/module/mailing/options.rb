# encoding: UTF-8
class Admin
class Mailing
class << self

  def no_template?
    @is_no_template = !!OPTIONS[:no_template][:value] if @is_no_template === nil
    @is_no_template
  end
  def template?
    !no_template?
  end

  def code_brut?
    @is_code_brut = !!OPTIONS[:code_brut][:value] if @is_code_brut === nil
    @is_code_brut
  end
  alias :code_html? :code_brut?

  def code_erb?
    @is_code_erb = !!OPTIONS[:code_erb][:value] if @is_code_erb === nil
    @is_code_erb
  end

  def signature_bot?
    @with_signature_bot = !!OPTIONS[:signature_bot][:value] if @with_signature_bot === nil
    @with_signature_bot
  end

  def force_offline?
    if @is_force_offline === nil
      if ONLINE
        @is_force_offline = false
      else
        @is_force_offline = !!OPTIONS[:force_offline][:value]
        if @is_force_offline
          flash "Noter que pour le moment, les envois depuis l'OFFLINE n'utilise pas la liste des users ONLINE. Donc il vaut mieux envoyer en ONLINE."
        end
      end
    end
    @is_force_offline
  end

end #/<< self
end #/Mailing
end #/Admin
