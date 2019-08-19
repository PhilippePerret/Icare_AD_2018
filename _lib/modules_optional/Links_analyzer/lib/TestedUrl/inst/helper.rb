# encoding: UTF-8
class TestedPage

  # Retourne un lien HTML pour la route/page courante
  #
  # Inauguré pour le fieldset des fréquences dans le rapport
  def link_to
    "<a href=\"#{url}\" target=\"_blank\">#{route}</a>"
  end

end
