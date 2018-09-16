# encoding: UTF-8

def le_texte str, options = nil
  TestString.new str, options
end

class TestString
  attr_reader :string
  attr_reader :options

  def initialize str, options = nil
    @string   = str
    @options  = options || Hash.new
  end

  # ---------------------------------------------------------------------
  #   Méthodes de test
  #
  #   NOTE
  #     * Elles doivent retourner obligatoirement 'self' pour le
  #       chainage.
  # ---------------------------------------------------------------------
  def contient search, args = nil
    @current_check_method = :contient
    args = extract_messages_from args
    args.empty? || @options = args
    search_init = search.freeze
    if _include? search
      success message_success || "#{string_reponse} contient “#{search_init}”."
    else
      raise (message_failure || "#{string_reponse} ne contient pas “#{search_init}”.") + texte_added_on_failure
    end
    return self
  end

  def ne_contient_pas search, args = nil
    @current_check_method = :ne_contient_pas
    args = extract_messages_from args
    args.empty? || @options = args
    search_init = search.freeze
    if _include? search
      raise message_failure || "#{string_reponse} ne devrait pas contenir “#{search_init}”."
    else
      success message_success || "#{string_reponse} ne contient pas “#{search_init}”."
    end
    return self
  end

  # def contient_la_balise tagname, args = nil
  #   @current_check_method = :contient_la_balise
  #   args = extract_messages_from args
  #   if a_balise?(tagname, args)
  #     success message_success || "#{string_reponse} contient la balise #{tagname_reponse}."
  #   else
  #     raise (message_failure || "#{string_reponse} ne contient pas la balise #{tagname_reponse}.") + texte_added_on_failure
  #   end
  #   return self
  # end
  # def ne_contient_pas_la_balise tagname, args = nil
  #   @current_check_method = :ne_contient_pas_la_balise
  #   args = extract_messages_from args
  #   if a_balise?(tagname, args)
  #     raise message_failure || "#{string_reponse} ne devrait pas contenir la balise #{tagname_reponse}."
  #   else
  #     success message_failure || "#{string_reponse} ne contient pas #{tagname_reponse}"
  #     return self
  #   end
  # end

  # On répète la méthode précédente
  def et arg, args = nil
    self.send(@current_check_method, arg, args)
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles de recherche
  # ---------------------------------------------------------------------
  def _include? str
    str =
      case str
      when String   then /#{Regexp.escape str}/
      when Regexp   then str
      end
    return string =~ str
  end

  attr_reader :tag_name, :tag_attrs

  def a_balise? tagname, attrs
    @tag_name   = tagname
    @tag_attrs  = attrs

    texte  = attrs.delete(:text)
    attrs.key?(:class) && attrs[:class] = attrs[:class].gsub(/ /, '.')
    c = String.new
    attrs.key?(:in) && c << attrs.delete(:in)
    c = tagname
    # puts "node.has_css?('#{tagname}') = #{node.has_css?(tagname).inspect}"
    attrs.key?(:id) && c << "##{attrs.delete(:id)}"
    # puts "node.has_css?('#{c}') = #{node.has_css?(c).inspect}"
    attrs.key?(:class) && c << ".#{attrs.delete(:class)}"
    # puts "node.has_css?('#{c}') = #{node.has_css?(c).inspect}"

    if texte
      texte_init = texte.freeze
      texte.instance_of?(Regexp) || texte = /#{Regexp.escape texte}/
      resultat = node.has_css?(c, text: texte)
      # Si le résultat est false, il faut essayer de donner le contenu textuel
      # actuel de la balise, si elle existe.
      # Pour rechercher, il faut impérativement qu'on puisse trouver la balise,
      # ce qui n'est pas le cas si plusieurs balises existent
      if !resultat
        cnode = node.find(c) rescue nil
        if cnode
          # On a trouvé une seule balise correspondante
          @texte_added_on_failure = " (la balise #{c} contient “#{cnode.text}”)."
        end
      end
    else
      resultat = node.has_css?(c)
    end
    return resultat
  end

  # ---------------------------------------------------------------------
  #   Méthodes de message pour la réponse
  # ---------------------------------------------------------------------
  def message_success; options[:success] || @message_success end
  def message_success= value; @message_success = value end
  def message_failure; options[:failure] || @message_failure end
  def message_failure= value; @message_failure = value end
  # Extrait les éléments pour le message de fin.
  # Va plus loin que ça en définissant par exemple le @in_container
  # lorsque l'élément doit être trouvé dans un container particulier
  def extract_messages_from args
    args ||= Hash.new
    @message_success = args.delete(:success)
    @message_failure = args.delete(:failure)
    @in_container = args.delete(:in)
    @with_text    = args[:text].nil_if_empty
    return args
  end

  # Le string à écrire dans la réponse
  def string_reponse
    if @in_container
      "Le container #{@in_container}"
    else
      "Le texte ”"+
      if string.length < 70
        string
      else
        string[0..35] + ' […] ' + string[-35..-1]
      end.gsub(/\n/,'\\n') + "”"
    end
  end
  # Le string à écrire dans la réponse quand c'est une
  # balise qui est recherchée
  def tagname_reponse
    c = "#{tag_name}"
    tag_attrs.key?(:id) && c << "##{tag_attrs[:id]}"
    tag_attrs.key?(:class) && c << ".#{tag_attrs[:class]}"
    @with_text && c << " avec le texte “#{@with_text}”"
    return c
  end

  def texte_added_on_failure
    @texte_added_on_failure || ''
  end

  # ---------------------------------------------------------------------
  #   Autres méthodes
  # ---------------------------------------------------------------------

  # Le texte comme nœud Capybara, pour être analysé avec les
  # méthode has_css? et autre
  def node
    @node ||= Capybara::Node::Simple.new(string)
  end

end #/TestString
