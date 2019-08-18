# encoding: UTF-8

def icmodule  ; @icmodule   ||= instance_objet      end
def icetape   ; @iceatpe    ||= owner.icetape       end
def absmodule ; @absmodule  ||= icmodule.abs_module end
def absetape  ; @absetape   ||= icetape.abs_etape   end


def next_abs_etape
  @next_abs_etape ||= begin
    site.require_objet 'abs_etape'
    AbsModule::AbsEtape.new(next_abs_etape_id)
  end
end
# L'ID absolu de la prochaine étant. Soit pris dans le menu, soit dans le
# champ pour le spécifier explicitement.
def next_abs_etape_id
  @next_etape_id ||= begin
    if numero_next_etape_explicite != nil
      abs_etape_id_next_etape_explicite
    else
      param(:next_etape).to_i
    end
  end
end

# Dans le cas où une étape a été précisée explicitement
def abs_etape_id_next_etape_explicite
  @aeinee ||= begin
    drequest = {
      where:      "module_id = #{absmodule.id} AND numero = #{numero_next_etape_explicite}",
      colonnes:   []
    }
    dbtable_absetapes.select(drequest).first[:id]
  end
end

# Si le numéro d'étape a été précisé explicitement, cette  méthode-
# propriété renvoie le numéro de l'étape (ATTENTION : PAS L'ID ABSOLU)
def numero_next_etape_explicite
  @numero_nee ||= begin
    nnee = param(:next_etape_explicite).nil_if_empty
    if nnee.nil?
      nil
    else
      nnee.to_i
    end
  end
end


def next_etape_designation
  "#{next_abs_etape.numero} : “#{next_abs_etape.titre}”"
end

# Pour savoir si l'étape précédente doit compte pour une vraie
# étape. Pour le moment, je ne me sers pas encore de ça
def prev_etape_is_real?
  param(:prev_etape_is_real) == 'on'
end
