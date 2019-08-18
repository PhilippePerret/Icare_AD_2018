# encoding: UTF-8

# Pour les snippets
OFFLINE || page.add_javascript(PATH_MODULE_JS_SNIPPETS)

class AbsModule
class AbsEtape
class AbsTravailType
  def param_id
    @param_id ||= dparam[:id].nil_if_empty
  end
  def save
    data_ok? || return
    if param_id == nil
      # = CRÉATION =
      @id = dbtable_travaux_types.insert(data2save.merge(created_at: Time.now.to_i))
      flash "Travail-type ##{id} créé."
    else
      # = MODIFICATION =
      dbtable_travaux_types.update(id, data2save)
      flash "Travail-type ##{id} modifié."
    end
  end

  def data2save
    @data2save ||= {
      titre:        dparam[:titre]      .nil_if_empty,
      rubrique:     (dparam[:rubrique]   .nil_if_empty || dparam[:new_rubrique].nil_if_empty),
      short_name:   dparam[:short_name] .nil_if_empty,
      objectif:     dparam[:objectif]   .nil_if_empty,
      travail:      dparam[:travail]    .nil_if_empty,
      methode:      dparam[:methode]    .nil_if_empty,
      liens:        dparam[:liens]      .nil_if_empty,
      updated_at:   Time.now.to_i
    }
  end
  def data_ok?
    data2save[:titre]     != nil || raise('Il faut définir le titre de ce travail-type.')
    data2save[:rubrique]  != nil || raise('Il faut définir la rubrique du travail-type.')
    data2save[:short_name]!= nil || raise('Il faut définir le nom court du travail-type.')
    data2save[:objectif]  != nil || raise('Il faut définir l’objectif du travail-type.')
    data2save[:travail]  != nil || raise('Il faut définir l’objectif du travail-type.')
    # data2save[:methode]  != nil || raise('Il faut définir la méthode du travail-type.')

  rescue Exception => e
    debug e
    error e
  else
    true
  end

  def dparam
    @dparam ||= param(:wtype)
  end
end #/AbsTravailType
end #/AbsEtape
end #/AbsModule


def menu_rubriques options = nil
  app.session['rubriques_wtypes'] ||= begin
    dbtable_travaux_types.select(colonnes:[:rubrique]).collect do |hwt|
      hwt[:rubrique]
    end.uniq.join(' ')
  end

  options ||= Hash.new
  selected = param(:wtype).nil? ? nil : param(:wtype)[:rubrique]
  options.merge!(
    selected: selected,
    name:     'wtype[rubrique]',
    id:       'wtype_rubrique',
    class:    'inline'
  )
  ([['', 'choisir la rubrique…']] + app.session['rubriques_wtypes'].split(' ').collect{ |r| [r, r] }).
    in_select(options)
end
def menu_travaux_types
  if param(:wtype) && param(:wtype)[:rubrique]
    req = {
      where:{rubrique: param(:wtype)[:rubrique]},
      colonnes: [:short_name]
    }
    ([['', 'Éditer le travail-type…']] +
    dbtable_travaux_types.select(req).collect do |hwt|
      [hwt[:id], hwt[:short_name]]
    end).in_select(name: 'wtype_id', class: 'inline', onchange:'this.form.submit()')
  else
    ''
  end
end

def champ_new_rubrique
  ''.in_input_text(placeholder: 'Nouvelle rubrique', name: 'wtype[new_rubrique]', id: 'wtype_new_rubrique', class: 'milong', style:'margin-left:1em', onchange: "$.proxy(AbsTravailType,'ondefine_new_rubrique')()")
end
def travailtype
  @travailtype ||= begin
    AbsModule::AbsEtape::AbsTravailType.new(wtype_id)
  end
end
def wtype_id
  @wtype_id ||= (param(:wtype_id) || site.current_route.objet_id).to_i
end

def explication_identifiant
  '(Supprimer l’identifiant pour créer un nouveau travail-type)'.in_span(class: 'tiny')
end
def explication_format_liens
  'Liste des liens, les uns en dessous des autres. Un lien peut être composé de<br><code>&lt;ID page&gt;::collection[::titre]</code> pour la collection narration ou<br><code>&lt;www.url.com&gt;::&lt;titre&gt;</code> pour n’importe quelle autre adresse.'
end
# Champ pour afficher les liens formatés
def champ_liens
  '<div id="liens_formated" class="small"></div>'
end

case param(:operation)
when 'save_travail_type'
  travailtype.save
end
