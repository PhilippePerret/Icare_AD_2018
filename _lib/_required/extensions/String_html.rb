# encoding: UTF-8
=begin

  Extension String pour les code HTML
  version 1.0.2

  # version 1.0.2
    La class, dans les attributs des balises, peut être donnée avec une
    liste Array.
    Lorsque les attributs définissent display:'none', on ajoute le style
    'display:none;'

  # version 1.0.1
    Développement de la méthode `in_image` pour traiter le cas où
    il y a une légende fournie.

=end
class String

  ##
  #
  # Épure le self en supprimant tout retour chariot et tous les
  # espaces superflus
  #
  #

  def epure_html
    str = self
    str.gsub!(/\n/,'')
    str.gsub!(/(\s)\s+/, '\1')

    ##
    ## On protège certaines espaces
    ## Les mots qui peuvent en avoir avant et après
    # with_spaces = ['a', 'span', 'i', 'em', 'b', 'strong', 'u', 'sup'].join('|')
    # str.gsub!(/\s\<(#{with_spaces})/, '_<\1')
    # str.gsub!(/\<\/(#{with_spaces})\>\s/, '</\1>_')

    @sans_espace ||= ['div', 'table', 'p', 'pre'].join('|')
    @reg_sans_espace_apres ||= /(\<(#{@sans_espace})\>)\s/
    @reg_sans_espace_avant ||= /\s(\<({@sans_espace})\>)/
    str.gsub!(@reg_sans_espace_apres, '\1')
    str.gsub!(@reg_sans_espace_avant, '\1')

    ##
    ## On déprotège les espaces
    ##
    # str.gsub!(/_\<(#{with_spaces})/, ' <\1')
    # str.gsub!(/\<\/(#{with_spaces})\>_/, '</\1> ')

    return str
  end

  class << self


    # Construction le code HTML de la balise d'ouverture de tabname +tag+ et
    # d'attributs optionnels +attrs+
    # NOTE: Toutes les valeurs nil sont retirées
    def opened_tag tag, attrs = nil
      attrs ||= Hash.new
      # La propriété :displayed indique si l'élément doit être
      # affiché ou non.
      #  La propriété :mask fait le contraire
      #  La propriété :visible indique si l'élément est visible
      displayed = attrs.delete(:displayed)
      nodisplay = attrs.delete(:mask)
      has_key_visible = attrs.has_key?(:visible)
      isvisible = attrs.delete(:visible)

      # Les balises pour Schema.org
      # Noter que `itemscope` n'est plus utilie puisqu'il est
      # ajouté chaque fois que itemtype est défini.
      if attrs.key?(:itemtype) # Schema.org
        itemscope = true
        itemtype  = "http://schema.org/#{attrs[:itemtype]}"
        attrs[:itemtype] = itemtype
      else
        # Item scope peut être employé sans itemtype, par exemple
        # pour une liste d'employés.
        itemscope = attrs.delete(:itemscope)
      end

      # Le style peut être fourni par un string ou un Hash
      if attrs[:style].class == Hash
        attrs[:style] = attrs[:style].collect do |prop, value|
          "#{prop}:#{value};"
        end.join('')
      end

      if nodisplay || displayed === false || attrs.has_key?(:display)
        display = case attrs.delete(:display)
        # when nil    then "none" # avec nodisplay et displayed=false
        when false, nil, 'none'  then "none"
        when true   then "block"
        else display
        end
        attrs[:style] ||= ""
        attrs[:style] += "display:#{display};#{attrs[:style]}"
      end

      if has_key_visible
        attrs[:style] ||= ""
        attrs[:style] += "visibility:#{isvisible ? 'visible' : 'hidden'}"
      end

      attrs[:class] = attrs[:class].join(' ') if attrs[:class] && attrs[:class].is_a?(Array)

      attrs =
        unless attrs.empty?
          " " + attrs.reject{|k,v| v.nil?}.collect do |k,v|
            "#{k}=\"#{v}\""
          end.join(' ')
        else
          ""
        end
      attrs += ' itemscope' if itemscope
      "<#{tag}#{attrs}>"
    end
  end #<< self


  # === Construction de balises HTML ===

  def as_span_libelle
    self.in_span(:class => 'libelle')
  end
  def as_span_value
    self.in_span(:class => 'value')
  end
  # Met le String dans une balise <tag> en mettant en attribut tous
  # les paramètres passés en argument.
  # @usage        <texte>.<tag>(<args)
  # @exemple      "Mon texte dans un div".in_div(:id => "mon_div", :class => "sa_class")
  # @params {attrs} attrs   Attributs optionnels de la balise
  # Méthode générique
  def html_balise tag, attrs = nil
    self.class.opened_tag(tag, attrs) + "#{self}</#{tag}>"
  end
  def in_h1       attrs = nil;  html_balise 'h1',       attrs end
  def in_h2       attrs = nil;  html_balise 'h2',       attrs end
  def in_h3       attrs = nil;  html_balise 'h3',       attrs end
  def in_h4       attrs = nil;  html_balise 'h4',       attrs end
  def in_h niv;   attrs = nil;  html_balise "h#{niv}",  attrs end
  def in_div      attrs = nil;  html_balise 'div',      attrs end
  def in_nav      attrs = nil;  html_balise 'nav',      attrs end
  def in_pre      attrs = nil;  html_balise 'pre',      attrs end
  def in_span     attrs = nil;  html_balise 'span',     attrs end
  def in_p        attrs = nil;  html_balise 'p',        attrs end
  def in_ul       attrs = nil;  html_balise 'ul',       attrs end
  def in_ol       attrs = nil;  html_balise 'ol',       attrs end
  def in_li       attrs = nil;  html_balise 'li',       attrs end
  def in_label    attrs = nil;  html_balise 'label',    attrs end
  def in_section  attrs = nil;  html_balise 'section',  attrs end
  def in_legend   attrs = nil;  html_balise 'legend',   attrs end
  def in_table    attrs = nil;  html_balise 'table',    attrs end
  def in_tr       attrs = nil;  html_balise 'tr',       attrs end
  def in_td       attrs = nil;  html_balise 'td',       attrs end

  def in_dl       attrs = nil;  html_balise 'dl',       attrs end
  def in_dt       attrs = nil;  html_balise 'dt',       attrs end
  def in_dd       attrs = nil;  html_balise 'dd',       attrs end

  # On peut passer des query-strings par :
  #   query_string: "var=val&var=val etc."
  #   query_string: {var: val, var: val etc.}
  #   query_string: [[var,val], [var, val] etc.]
  # L'avantage des versions par Hash et par Array est que la valeur
  # est escapé par CGI, contrairement à la version par String qui n'est
  # pas touchée.
  def in_a attrs = nil
    attrs ||= Hash.new
    qs = attrs.delete(:query_string)
    if attrs.key?(:href)
      unless qs.nil?
        href = attrs[:href]
        href += href.match(/\?/) ? '&' : '?'
        href += case qs
        when Hash   then qs.collect{|var,val| "#{var}=#{CGI::escape val}"}.join('&')
        when Array  then qs.collect{|paire| "#{paire.first}=#{CGI::escape paire.last}"}.join('&')
        when String then qs
        end
        attrs[:href] = href
      end
    else
      attrs.merge!( :href => 'javascript:void(0)' )
    end
    if attrs.key?(:target)
      attrs[:target] =
        case attrs[:target]
        when :new, :blank then '_blank'
        else attrs[:target]
        end
    end
    html_balise 'a', attrs
  end

  # Noter que pour générer de façon complexe un select, il faut
  # aller voir dans l'extension Array.
  def in_select attrs = nil;  html_balise 'select',   attrs end
  # Pour un menu plus souple que select>option
  def in_my_select attrs = nil
    attrs[:class] ||= ''
    attrs[:class] << ' myselect'
    attrs[:class] = attrs[:class].strip

    # La taille du menu peut être déterminé par :width
    size = attrs.delete(:size) || 'normal'

    # Il faut ajouter un champ hidden qui contiendra vraiment
    # la valeur avec le nom déterminé
    fid   = attrs[:id]   || attrs[:name]
    fname = attrs[:name] || attrs[:id]
    attrs[:id]    = "myselect_#{fid}"
    attrs[:name]  = "myselect_#{fname}"
    "<div class=\"container_myselect #{size}size\">" +
      attrs[:selected].in_hidden(id: fid, name: fname) +
      self.class.opened_tag('div', attrs) + self.to_s + '</div>' +
    '</div>'
  end

  # Ajouter :file => true dans +attrs+ pour une formulaire avec upload fichier
  def in_form     attrs = nil
    attrs ||= Hash.new
    attrs.merge!( method: 'POST' ) unless attrs.has_key?(:method)
    attrs.merge!( 'accept-charset' => "UTF-8") unless attrs.has_key?('accept-charset')
    if attrs.has_key?( :file ) && attrs.delete(:file) == true
      attrs.merge!(:enctype => 'multipart/form-data')
    end
    html_balise 'form', attrs
  end
  def in_option attrs = nil
    attrs ||= Hash.new
    attrs[:selected] = "SELECTED" if attrs.delete(:selected) === true
    html_balise 'option',   attrs
  end
  def in_my_option attrs = nil
    attrs ||= Hash.new
    attrs[:class] ||= ''
    if attrs.delete(:selected) === true
      attrs[:class] << ' selected'
    end
    # html_balise 'myoption',   attrs
    attrs[:class] << ' myoption'
    attrs[:class] = attrs[:class].strip

    # Quand on clique sur ces div, ils doivent déclencher
    # la méthode onChangeMySelect()
    # attrs[:onclick] ||= ''
    # attrs[:onclick].prepend('onChangeMySelect(this);')

    self.class.opened_tag('div', attrs) + self.to_s + '</div>'
  end
  def in_input    attrs = nil
    attrs ||= Hash.new
    attrs = attrs.merge( :value => self ) unless self == "" || attrs.has_key?(:value)
    self.class.opened_tag('input', attrs)[0..-2] + " />"
  end
  def in_input_text attrs = nil
    attrs = attrs.merge(type: 'text')
    in_input attrs
  end
  def in_textarea attrs = nil
    html_balise 'textarea', attrs
  end
  # `self' est utilisé comme name, on ajouter "file_" avant pour l'identifiant
  def in_input_file attrs = nil
    attrs ||= Hash.new
    attrs.merge!( type: 'file', value: "" )
    attrs.merge!( name: self ) unless attrs.has_key?( :name )
    unless attrs.has_key?( :id )
      attrs.merge! :id => "file_" + (self == "" ? attrs[:name] : self)
    end
    attrs.merge!(id: attrs[:id])
    in_input attrs
  end
  def in_password attrs = nil
    attrs = attrs.merge(type: 'password')
    in_input attrs
  end
  def in_radio attrs
    attrs = attrs.merge type: 'radio'
    self.in_checkbox attrs
  end
  def in_checkbox attrs
    is_radio = attrs[:type] == 'radio'
    label = attrs.delete(:label)
    label = self if label.nil?
    label_class = Array::new
    label_class << 'cb'
    label_class << attrs.delete(:label_class)
    label_class = label_class.compact.join(' ')
    checked = attrs.delete(:checked)
    attrs = attrs.merge( :checked => "CHECKED" ) if checked === true
    unless attrs.has_key? :id
      prefix = attrs[:prefix] || (is_radio ? 'ra' : 'cb')
      suffix = attrs[:suffix] || (is_radio ? attrs[:value].as_normalized_id : '')
      attrs = attrs.merge(id: "#{prefix}_#{attrs[:name]}#{suffix}")
    end
    unless attrs.has_key? :type # arrive pour les radios
      attrs = attrs.merge(type: "checkbox")
    end

    # Class du span contenant le CB et le label
    attrs[:class] ||= Array::new
    attrs[:class] = [attrs[:class]] if attrs[:class].class == String
    attrs[:class] << (is_radio ? 'ra' : 'cb')

    span_class = attrs.delete(:class)
    span_class = span_class.join(' ')
    # Code retourné
    (
      "".in_input(attrs.merge(class: 'form-check-input')) +
      label.in_label(for: attrs[:id], class: 'form-check-label')
    ).
      in_div(class: 'form-check').
      in_div(class:'form-group')
  end

  def in_hidden attrs = nil
    self.in_input(attrs.merge :type => 'hidden')
  end
  # Le String est le nom du bouton
  def in_submit attrs = nil
    attrs ||= Hash.new
    a_droite  = attrs.delete(:right)
    au_centre = attrs.delete(:center)
    f = "".in_input(attrs.merge(:value => self, :type => 'submit'))
    # Valeur retournée
    case true
    when a_droite   then f.in_div(class: 'right')
    when au_centre  then f.in_div(class: 'center')
    else f
    end
  end
  def in_button attrs = nil; "".in_input((attrs||{}).merge :value => self, :type => 'button') end

  ##
  #
  # RETURN code pour une image
  #
  # +self+ est le path
  # +attrs+
  #   :center => true
  #       L'image sera placée dans un div centré. La classe .center doit être
  #       définie dans les CSS.
  #   :air    => true
  #       L'image sera mis dans un div "air", donc avec de l'air autour
  #   :float  => 'left'/'rigth'
  #       L'image sera placée dans un div flottant à droite ou à gauche.
  #       Noter que la class 'div.air' sera ajoutée, qui doit définir l'air
  #       à laisser autour de l'image.
  #       Les classes 'fleft' et 'fright' doivent être définies.
  #   :legend => "<texte de la légende>"
  #       Si :legend est défini dans les attributs, l'image est retournée
  #       dans un cadre (non visible) avec une légende.
  #       Le style par défaut est 'img_legend' pour le DIV contenant la légende
  #       Le style par défaut pour le div contenant l'image et la légende
  #       est .img_cadre.
  #       On peut sur définir ces valeurs avec les propriétés attrs suivantes :
  #         legend_class:     Nouvelle class CSS pour le div légend
  #         div_class:        Nouvelle class CSS pour le div général
  #
  # Alias : def in_img
  def in_image attrs = nil
    attrs ||= Hash.new
    attrs.merge!( src: self ) unless self == "" || attrs.has_key?(:src)
    legend        = attrs.delete(:legend)
    if legend
      legend_class  = attrs.delete(:legend_class) || []
      legend_class = [legend_class] unless legend_class.is_a?(Array)
      legend_class << 'legend'
      div_class     = attrs.delete(:div_class)    || []
      div_class = [div_class] unless div_class.is_a?(Array)
      div_class << 'image-with-legend'
    end
    centrer_image   = attrs.delete(:center)
    with_air        = attrs.delete(:air)
    image_flottante = attrs.delete(:float)
    if attrs[:size]
      attrs[:style] ||= ''
      attrs[:style] << "width:#{attrs.delete(:size)}"
    end

    ##
    ## Le tag IMG
    ##
    tag_img = self.class.opened_tag('img', attrs)[0..-2] + ' />'

    ##
    ## S'il y a une légende
    ## (il faut alors mettre le tout dans un cadre (qui sera flottant
    ##  si l'image doit être flottante))
    ##
    tag = if legend
      div_legend = legend.in_div(class: legend_class.join(' '))
      div_image  = tag_img.in_div(class: 'image')
      div_class << "f#{image_flottante}" if image_flottante
      (div_image + div_legend).in_div(class: div_class.join(' '))
    else
      tag_img
    end

    css = []
    css << 'center' if centrer_image
    css << 'air'    if with_air

    ##
    ## Si l'image doit être centrée ou floattant
    ##
    if legend
      tag
    else
      if centrer_image
        tag.in_div(class: css.join(' '))
      elsif image_flottante != nil
        tag.in_div(class: "f#{image_flottante}")
      else
        tag
      end
    end
  end
  alias :in_img :in_image

  def in_fieldset attrs = nil
    code =
    if attrs && attrs.has_key?(:legend)
      "<legend>#{attrs.delete(:legend)}</legend>"
    else
      ""
    end + self
    self.class.opened_tag('fieldset', attrs) + code + "</fieldset>"
  end

  # Correspond à to_html mais seulement si le string ne commence pas par '<'
  def htmlize
    return self if self.strip.start_with? '<'
    str = self
    str = "<div>#{str}</div>"
    str.to_html
  end
  alias :htmalize :htmlize

  # Met les textes séparés par des doubles retours chariot dans des div
  def return_to_div
    self.split("\n\n").collect{|e| "<div>#{e}</div>"}.join("\n")
  end

  # Htmlize le string
  # Pour le moment, ne traite plus que les retours chariot
  def to_html
    str = self
    str.gsub!(/\r/,'')
    str = str.split("\n\n").collect { |p| "<p>#{p}</p>" }.join('')
    str.gsub(/\n/,'<br />')
    return str
  end

end
