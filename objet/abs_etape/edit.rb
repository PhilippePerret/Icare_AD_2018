# encoding: UTF-8
raise_unless_admin

site.require_objet 'abs_module'

# Pour les snippets
OFFLINE || page.add_javascript(PATH_MODULE_JS_SNIPPETS)

# Étape courante
# --------------
# Si l'étape a un identifiant nil, c'est qu'un module a été
# choisi : on doit prendre la première de ses étapes
def absetape
  @absetape ||= begin
    etape_id =
      if site.current_route.objet_id
        site.current_route.objet_id
      else
        mod_id = param(:abs_module_id).to_i
        dbtable_absetapes.get(where:{module_id: mod_id, numero: 1})[:id]
      end
    AbsModule::AbsEtape.new(etape_id)
  end
end

def absmodule
  @absmodule ||= begin
    if absetape.id
      absetape.abs_module
    else
      AbsModule.new(param(:abs_module_id).to_i)
    end
  end
end

# ---------------------------------------------------------------------
#   Méthodes d'helper
# ---------------------------------------------------------------------
# Champ pour afficher les liens qui seront formatés en véritable
# lien cliquable.
def champ_liens
  '<div id="liens_formated" class="small"></div>'
end
def menu_modules
  menu_modules_values.in_select(
    id: 'menu_modules', name: 'abs_module_id',
    class:    'inline blue bold',
    onchange: "$.proxy(AbsEtape,'onchoose_module')()",
    selected: absmodule.id)
end
def menu_modules_values
  dbtable_absmodules.select(colonnes:[:name]).collect do |hmod|
    [hmod[:id], "#{hmod[:name]} (#{hmod[:id]})"]
  end
end

# Retourne un menu de toutes les étapes du module choisi (param :abs_module_id)
# mises en forme. L'étape courante est sélectionnée et le menu permet d'en
# choisir une autre
def menu_etapes_module
  abs_module_id = (param(:abs_module_id) || absmodule.id).to_i
  drequest = {
    where: "module_id = #{abs_module_id}",
    colonnes: [:titre, :numero],
    order: 'numero ASC'
  }
  dbtable_absetapes.select(drequest).collect do |hetape|
    opt_value = hetape[:id]
    opt_titre = "#{hetape[:numero]}. #{hetape[:titre]} (##{hetape[:id]})"
    [ opt_value, opt_titre, hetape[:id] == absetape.id ]
  end.in_select(
    id: 'menu_etapes', name: 'abs_etape_id',
    class: 'inline blue bold',
    onchange: "$.proxy(AbsEtape,'onchoose_etape')()",
    selected: absetape.id
    )
end

def explication_identifiant
  '(Supprimer l’identifiant pour créer une nouvelle étape)'.in_span(class: 'tiny')
end
def explication_format_liens
  'Liste des liens, les uns en dessous des autres. Un lien peut être composé de<br><code>&lt;ID page&gt;::collection[::titre]</code> pour la collection narration ou<br><code>&lt;www.url.com&gt;::&lt;titre&gt;</code> pour n’importe quelle autre adresse.'
end

# ---------------------------------------------------------------------
#   Méthodes pour l'enregistrement
# ---------------------------------------------------------------------
class AbsModule
class AbsEtape
class << self
  # Création ou modification de l'étape courante
  def save
    data
    if creation?
      # Créer la données en local et en offline
      data[:id] = dbtable_absetapes.insert(data)
      ONLINE || table_online.insert(data)
      flash "L'étape ##{data[:id]} a été créée ONLINE et OFFLINE avec succès."
      redirect_to "abs_etape/#{data[:id]}/edit"
    else
      # Modification d'une étape
      hmodifs = Hash.new # pour mettre les données modifiées
      data.each do |k, v|
        if v != data_actuelles[k]
          hmodifs.merge!(k => v)
        end
      end

      # Modifier dans la table locale et distante
      dbtable_absetapes.update(data[:id], hmodifs)
      ONLINE || table_online.update(data[:id], hmodifs)
      # Message de confirmation
      flash "L'étape ##{data[:id]} a été modifiée ONLINE et OFFLINE avec succès."
    end
  end

  def table_online
    @table_online ||= site.dbm_table(:modules, 'absetapes', online = true)
  end
  def creation?
    data_initiales[:id].nil?
  end

  # Les données telles qu'enregistrées dans la table pour
  # le moment
  def data_actuelles
    @data_actuelles ||= dbtable_absetapes.get(data[:id])
  end

  # Les données, préparées (mais pas encore vérifiées)
  def data
    @data ||= begin
      d = Hash.new
      param(:etape).each do |k, v|
        v = v.nil_if_empty
        v != nil && v.numeric? && v = v.to_i
        v.instance_of?(String) && v = v.gsub(/\r/, '').gsub(/\n+/, "\n")
        d.merge!(k => v)
      end
      d.merge!(updated_at: Time.now.to_i)
      d[:id] != nil || d.merge!(created_at: d[:updated_at])
      debug "données initiales : #{d.pretty_inspect}"
      @data_initiales = d.dup
      d
    end
  end
  def data_initiales ; @data_initiales end
end #/<< self
end #/AbsEtape
end #/AbsModule


# ---------------------------------------------------------------------
#   Dispatch de l'opération
# ---------------------------------------------------------------------
case param(:operation)
when 'save_etape'
  AbsModule::AbsEtape.save
end
