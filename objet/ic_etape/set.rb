# encoding: UTF-8
=begin

  Module qui sert à définir des valeurs de l'ic-étape en utilisant la route :

      ic_etape/<id ic-etape>/set

  Et des données placées dans :

      param(:property)
        :name     Le nom de la propriété
        :value    La valeur de la propriété
        :type     Le type ('String', 'Fixnum', 'Float')

        (qui peuvent être placés dans un formulaire par exemple)

  ATTENTION : ce genre de route est très vulnérable. Il faut vraiment s'assurer
  que l'opération est possible et saine.

=end
def icetape
  @icetape ||= IcModule::IcEtape.new(site.current_route.objet_id)
end
def property
  @property ||= param(:property)
end

begin

  property[:value] =
    case property[:type]
    when 'Fixnum' then property[:value].to_i
    when 'Float'  then property[:value].to_f
    else property[:value]
    end


  case property[:name]
  when 'expected_end'
    user.icetape.id == icetape.id || user.admin? || raise
  else
    raise
  end


  # ---------------------------------------------------------------------
  #   Tout est OK on peut enregistrer la propriété
  # ---------------------------------------------------------------------
  icetape.set(property[:name].to_sym => property[:value])

  case property[:name]
  when 'expected_end'
    flash "Votre nouvelle échéance a été prise en compte, #{user.pseudo}. Vous devrez remettre votre travail pour le #{property[:value].as_human_date(true, true, ' ', 'à')}"
  end


rescue Exception => e
  mess = e.message.nil_if_empty || 'Vous n’êtes pas autorisé à modifier cette propriété d’étape !'
  debug e
  error e.message
ensure
  redirect_to :last_page
end
