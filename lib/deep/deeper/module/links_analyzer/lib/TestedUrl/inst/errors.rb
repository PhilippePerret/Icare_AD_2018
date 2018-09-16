# encoding: UTF-8
=begin

=end
class TestedPage

  # Méthode principale pour indiquer que la page est invalide
  def set_invalide
    @is_valide = false
    self.class.add_invalide route
    if VERBOSE
      say "#{RETRAIT}# INVALIDE"
      say "#{RETRAIT}# LAST REFERER : #{call_froms.last}"
    end
  end

  # Consigner une erreur dans @errors
  def error err
    @errors << err
  end


end #/TestedPage
