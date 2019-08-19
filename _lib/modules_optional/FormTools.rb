# encoding: UTF-8
=begin

@usage

  site.require 'form_tools'

=end
class Page
class FormTools
class << self

  # Définition et restitution du prefixe qui servira pour les
  # NAME et ID des champs d'édition
  def prefix; @prefix end
  def prefix= value
    @prefix = value
  end

  # Définition des champs à mettre en exergue (une
  # exergue "douce", pas comme error_fields)
  def exergue_fields; @exergue_fields ||= [] end
  # +value+ {Array} des clés de champs à mettre en
  # exergue simple
  def exergue_fields= value
    @exergue_fields = value
  end
  # Retourne ' exergue' si le champ +nfield+ doit
  # être mis en exergue
  def exergue_field? nfield
    exergue_fields.include?(nfield) ? " exergue" : ""
  end

  # Définition des champs à mettre en exergue forte,
  # comme après une erreur (rouge)
  def error_fields;  @error_fields ||= [] end
  def error_fields= value
    @error_fields = value
  end
  def error_field? nfield
    error_fields.include?(nfield) ? " error" : ""
  end

  # Définition de l'objet qui contient actuellement
  # les valeurs. Sert à donner une valeur aux champs si
  # elles ne sont pas définies dans le formulaire (3e donnée)
  # C'est un Hash ou un objet. Si c'est un hash, les propriétés
  # seront considérées comme des clés (objet[<prop>]) sinon, elles
  # seront considérées comme des méthodes-propriétés.
  def objet
    @objet
  end
  def objet= value
    # debug "objet mis à #{value.pretty_inspect}"
    @objet = value
  end
  def objet_hash?
    if @is_objet_hash === nil
      @is_objet_hash = !!objet.instance_of?(Hash)
    end
    @is_objet_hash
  end

  # Pratique pour faire `form.objet_id` dans la vue
  def objet_id
    @objet_id ||= begin
      if objet.nil?
        nil
      else
        objet_hash? ? objet[:id] : objet.id
      end
    end
  end


  # ---------------------------------------------------------------------
  #   Les différents types de champ
  #   Méthodes à appeler à l'aide de la syntaxe :
  #     form.field_<tyle> "<libelle>", "<property>", selected[, options]
  # ---------------------------------------------------------------------

  def field_hidden libelle, prop, selected = nil, options = nil
    f = Field.new(:hidden, libelle, prop, selected, options)
    f.field_value.in_hidden(name:f.field_name, id:f.field_id)
  end
  def field_select libelle, prop, selected = nil, options = nil
    Field.new(:select, libelle, prop, selected, options).form_row
  end
  def field_select_pays libelle, prop, selected = nil, options = nil
    Field.new(:select_pays, libelle, prop, selected, options).form_row
  end
  alias :field_select_country :field_select_pays

  def field_textarea libelle, prop, value = nil, options = nil
    Field.new(:textarea, libelle, prop, value, options).form_row
  end

  # Un input-text
  def field_text libelle, prop, value = nil, options = nil
    Field.new(:text, libelle, prop, value, options).form_row
  end

  # Un input-checkbox
  def field_checkbox libelle, prop, value = nil, options = nil
    Field.new(:checkbox, libelle, prop, value, options).form_row
  end

  # Un champ pour un fichier
  def field_file libelle, prop, value = nil, options = nil
    Field.new(:file, libelle, prop, value, options).form_row
  end

  # Quand le code du champ est donné de façon brute
  # Note +options[:field]+ contient le code qui sera mis
  def field_raw libelle, prop, value = nil, options
    Field.new(:raw, libelle, prop, value, options).form_row
  end

  # Une simple description du champ, qui sera mise en petit
  # et en italique
  # @usage : form.description("<la description>")
  def field_description description, options = nil
    (
      "".in_span(class:'libelle') +
      description.in_span(class:'value descfield')
    ).in_div(class:'row description')
  end

  # Ligne de spération
  def separator
    @separator ||= begin
      "<div class='row'><span class='libelle'></span><span class='value'><div class='separator'></span></div></div>"
    end
  end
  # Le bouton submit
  def submit_button button_name, options = nil
    options ||= Hash.new
    button_name.in_submit(options.merge(class:'btn btn-primary')).
      in_div(class:'row right center-mobile').
      in_div(class:'container')
  end


end # << self FormTools


# ---------------------------------------------------------------------
#   Instance Page::FormTools::Field
#   -------------------------------
#   Pour la construction d'un champ en particulier
# ---------------------------------------------------------------------
class Field

  # {Symbol} Le type de champ, parmi :text, :textarea, :select,
  # etc.
  attr_reader :type
  attr_reader :libelle
  attr_reader :property
  attr_reader :field_value
  attr_reader :raw_options
  # Gestionnaires d'évènement
  attr_reader :onchange
  attr_reader :onclick
  attr_reader :onsubmit
  # Aspect spéciaux
  attr_reader :exergue
  attr_reader :warning
  attr_reader :confirmation
  attr_reader :row_class

  # Instanciation
  # +prop+ {String} La propriété
  def initialize type, libelle, prop, default, opts
    @type           = type
    @raw_options    = opts
    @property       = prop
    @field_value    = set_field_value(prop, default)
    @libelle        = libelle || '&nbsp;'

    # Les gestionnaires d'évènement
    unless opts.nil?
      @onchange     = opts.delete(:onchange)
      @onclick      = opts.delete(:onclick)
      @onsubmit     = opts.delete(:onsubmit)
      @exergue      = opts.delete(:exergue)
      @warning      = opts.delete(:warning)
      @confirmation = opts.delete(:confirmation)
      @row_class    = opts.delete(:row_class)
    end
    # Pour supprimer le libellé et le mettre en label dans un
    # checkbox
    cb_label if type == :checkbox

  end

  # ---------------------------------------------------------------------
  #   Méthodes de données
  # ---------------------------------------------------------------------

  # Méthode qui essaie de définir la valeur à donner
  # au champ de données dans le formulaire. Cette valeur peut être
  # donnée et obtenue de différentes manières :
  #   - de façon explicite en troisième argument
  #   - dans l'objet de la classe (form.objet)
  #   - dans les paramètres contenant l'objet
  def set_field_value prop, defvalue
    # debug "[set_field_value] Recherche d'une valeur pour `#{prop}`"

    # Valeur qui peut se trouver dans les paramètres, tel
    # quel ou dans un prefix défini
    param_value = begin
      if Page::FormTools.prefix.nil?
        param(prop.to_sym)
      else
        (param(Page::FormTools.prefix)||Hash.new)[prop.to_sym]
      end.nil_if_empty
    rescue Exception => e
      # Ça peut survenir par exemple lorsque c'est un champ
      # de type file
      nil
    end

    # debug "param_value = #{param_value.inspect}"

    # debug "[set_field_value] param_value : #{param_value.inspect}"

    # Valeur qui peut se trouver dans l'objet, si un objet
    # a été déterminé, qui peut être une instance ou un hash
    # Cf. la propriété `objet`
    objet_value =
      if Page::FormTools.objet != nil
        if Page::FormTools.objet_hash?
          Page::FormTools.objet[prop.to_sym]
        elsif Page::FormTools.objet.respond_to?(prop.to_sym)
          Page::FormTools.objet.send(prop.to_sym)
        else
          nil
        end
      end.nil_if_empty

    objet_value.instance_of?(String) && objet_value = objet_value.force_encoding('utf-8')

    # debug "objet_value = #{objet_value.inspect}"

    # debug "[set_field_value] objet_value  : #{objet_value.inspect}"
    # debug "[set_field_value] defvalue     : #{defvalue.inspect}"

    param_value || objet_value || defvalue || ""
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction
  # ---------------------------------------------------------------------

  # RETURN le code complet de la rangée
  def form_row
    (
      span_libelle +
      span_value   +
      code_javascript # if any
    )
    .in_div(class:form_row_css) + confirmation_field
  end

  def form_row_css
    (
      "form-group " + # bootstrp
      "row" +
      Page::FormTools.exergue_field?(property) +
      Page::FormTools.error_field?(property) +
      (row_class || "")
    ).strip
  end

  # Si les options contiennent confirmation:true,
  # il faut faire un champ de confirmation du champ
  # courant. Ce sera le même champ avec un name
  # différent et un libellé différent
  def confirmation_field
    return "" unless @confirmation
    [:field_name, :field_id, :field_attrs, :span_libelle, :span_value, :field_value].each do |key|
      instance_variable_set("@#{key}", nil)
    end
    @libelle    = "Confirmation de #{libelle}".capitalize
    @property   = "#{property}_confirmation"
    @fied_value = set_field_value( @property, "" )
    (
      span_libelle +
      span_value
    )
    .in_div(class:'row')
  end

  # RETURN le code du libellé
  # -------------------------
  def span_libelle
    @span_libelle ||= begin
      "<label for=\"#{field_id}\">#{libelle}</label>"
      # libelle.to_s.in_span( class: options[:span_libelle_class] )
    end
  end

  # RETURN {StringHTML} le code du span contenant la
  # valeur, c'est-à-dire le champ d'édition
  def span_value
    @span_value ||= begin
      text_before + field + text_after
      # (
      #   text_before + field + text_after
      # )
      # .in_span(class: options[:span_value_class])
    end
  end

  # Retourne le code HTML/Javascript permettant de sélectionner
  # certaines valeurs par javascript.
  # Cela est nécessaire pour palier le fait que les select n'affichent
  # pas toujours la valeur sélectionnée malgré l'insertion correcte
  # d'un SELECTED.
  # Note : Ce code ne sert que pour le select courant.
  # OBSOLÈTE
  def code_javascript
    return '' #if @javascripts.nil?
    # "<script type='text/javascript'>"+@javascripts.join(";\n")+"</script>"
  end

  # {StringHTML} Return le champ d'édition seul
  def field
    self.send( "field_#{type}".to_sym )
  end

  # ---------------------------------------------------------------------
  #   Méthodes renvoyant le champ d'édition en fonction du
  #   type
  # ---------------------------------------------------------------------

  def field_file
    field_value.to_s.in_input_file( field_attrs )
  end
  def field_text
    field_value.to_s.in_input_text( field_attrs )
  end
  def field_textarea
    field_value.to_s.in_textarea( field_attrs )
  end
  def field_select
    case options[:values]
    when String, Hash, Array
      if options[:values].instance_of?(Hash)
        options[:values] = options[:values].collect{ |k,v| [k, v[:hname]] }
      end
      selected = options[:selected] || field_value
      add_javascript "$('select##{field_id}').val('#{selected}')" unless selected.nil?
      options[:values].in_select( field_attrs.merge( selected:selected ) )
    else
      raise "Je ne sais pas comment traiter une donnée de class #{options[:values].class} dans `field_select` (attendu : un Hash, un Array ou un String)."
    end
  end

  def add_javascript code
    @javascripts ||= Array::new
    @javascripts << code
    # debug "code ajouté : #{code}"
  end
  # Un menu standard pour choisir un pays
  def field_select_pays
    @options ||= Hash.new
    @options.merge! values: PAYS_ARR_SELECT
    field_select
  end
  def field_checkbox
    # Note : Pour un champ checkbox, le libellé sert de texte pour la
    # case à cocher, pas de libellé (qui est supprimé par défaut)
    <<~EOC
    <div class="form-group">
      <div class="form-check">
        <input class="form-check-input" type="checkbox" name="#{field_name}" id="#{field_id}" #{field_value=='on' ? ' CHECKED' : ''}>
        <label class="form-check-label" for="#{field_id}">#{cb_label}</label>
      </div>
    </div>
    EOC
    # cb_label.in_checkbox( field_attrs.merge(checked: (field_value == 'on' || field_value == true)) )
  end

  def field_radio

  end
  def field_raw
    options[:field]
  end

  # ---------------------------------------------------------------------
  #   Méthodes de valeurs volatiles
  # ---------------------------------------------------------------------

  def field_attrs
    @field_attrs ||= begin
      h = { name:field_name, id:field_id, class:field_class }
      options[:placeholder] .nil?  || h.merge!(placeholder: options[:placeholder])
      options[:style]       .nil?  || h.merge!(style: options[:style])
      onclick.nil?  || h.merge!(onclick: onclick)
      onchange.nil? || h.merge!(onchange: onchange)
      onsubmit.nil? || h.merge!(onsubmit: onsubmit)

      h
    end
  end

  # Class CSS du champ
  def field_class
    css = (options[:class]||"").split(' ')
    css << 'exergue' if exergue
    css << 'warning' if warning
    css << 'form-control' # bootstrap
    css.join(' ')
  end

  # Le texte avant le champ d'édition. Renvoie un string vide
  # si aucun texte avant n'est défini.
  def text_before
    @text_before ||= begin
      t = options.delete(:text_before).nil_if_empty
      t.nil? ? "" : t.in_span
    end
  end
  # Le texte après le champs d'édition. Renvoie un string vide
  # si aucun texte après n'est défini.
  def text_after
    @text_after ||= begin
      t = options.delete(:text_after).nil_if_empty
      t == nil ? "" : t.in_span
    end
  end

  # NAME du champ
  def field_name
    @field_name ||= (prefix ? "#{prefix}[#{property}]" : property)
  end
  # ID du champ
  def field_id
    @field_id ||= (prefix ? "#{prefix}_#{property}" : property)
  end
  # Raccourci pour le préfix du nom/id de champ
  # Il peut être défini par form.prefix = "<prefix>" avant la construction
  # des champs du formulaire
  def prefix  ; @prefix ||= Page::FormTools::prefix end

  def cb_label
    @cb_label ||= begin
      lib = libelle.to_s.freeze
      @libelle = options[:libelle] || "&nbsp;"
      lib
    end
  end
  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------

  # Options par défaut pour n'importe quelle rangée de formulaire
  def options
    @options ||= begin
      opts = raw_options || Hash.new
      opts[:libelle_class] ||= ['libelle']
      opts[:libelle_class] << opts[:libelle_width] if opts[:libelle_width]
      opts[:span_libelle_class] = opts.delete(:libelle_class).join(' ')
      opts[:span_value_class] ||= 'value'
      opts
    end
  end

end # /Field
end # /FormTools
end # /Page

def form
  @form ||= Page::FormTools
end
