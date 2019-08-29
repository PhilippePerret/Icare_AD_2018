#!/Users/philippeperret/.rbenv/versions/2.6.3/bin/ruby
# encoding: UTF-8
=begin

  Pour ne pas avoir à créer un DSL pour les formulaires, mais pouvoir
  utiliser une forme simple, j'utilise ce script.

  Principes :
    - une inclusion correspond à une tabulation (
    - une espace est un séparateur de données, sauf dans les strings
    )

  @usage

    site.require_module 'Form2Code'
    FormToCode.new(<code|path>).to_html
    # => retourne le code HTML correspondant au code <code>

    site.require_module 'Form2Code'
    FormToCode.new(<path>).build
    # => Construit le fichier ERB avec le code html correspondant au fichier
    #    donné en path.

=end

class FormToCode

  RC = "
  "

  # {String} Chemin d'accès au fichier contenant le DSL du formulaire, s'il
  # a été fourni
  attr_reader :path

  # {String} Le code DSL du formulaire
  attr_reader :code

  attr_reader :owner

  def initialize codeOrPath, owner = nil
    @code =
      if File.exists?(codeOrPath)
        @path = codeOrPath
        File.read(codeOrPath).force_encoding('utf-8')
      else
        codeOrPath
      end

    @owner = owner
  end

  # Méthode principale qui transforme le code en code HTML
  def translate
    prepare
    to_html
  end

  def prepare
    # On remplace tous les espaces par des '_SP_' dans les strings
    @code.gsub!(/(['"])(.+?)\1/){
      sign = $1
      contenu = $2
      "#{sign}#{contenu.gsub(/ /,'__SP__')}#{sign}"
    }
  end
  def to_html
    closed_tags = []
    current_indentation = 0
    html_lines = []
    lines.each do |line|
      unless line.indentation + 1 > closed_tags.count
        # <= L'indentation de la ligne est inférieure à l'indentation courante
        # => Il faut désindenter de la même valeur
        begin
          tag_end = closed_tags.pop
          html_lines << tag_end
        end while closed_tags.count > line.indentation
      end

      html_lines << line.to_html

      # Dans tous les cas on mémorise la tag fermante courante
      closed_tags << line.closed_tag

    end # /Boucle sur toutes les lignes

    # On ajoute toutes les tags finales
    begin
      html_lines << closed_tags.pop
    end until closed_tags.empty?

    html_lines.join('')
  end

  def lines
    @lines ||= begin
      code.split("\n").collect do |line|
        line_strip = line.strip
        next if line_strip.empty? || line_strip.start_with?('#')
        line = line.rstrip
        line_ind = line.gsub(/\t/, '  ')
        indent   = line_ind[/^ */].size / 2
        # puts "LINE:#{line} / indent: #{indent}"
        Line.new(self, indent, line)
      end.compact
    end
  end #/lines

  # Construction du fichier ERB à partir du code du path fourni
  def build owner = nil
    path || raise("Il faut instancier l'objet avec le chemin d'accès au code non formaté.")
    owner && @owner = owner
    File.open(erb_path,'wb'){|f| f.write self.translate}
  end

  # Path au fichier ERB contenant le code construit si un :path a
  # été fourni à l'instanciation
  def erb_path
    @erb_path ||= File.join(File.dirname(path), erb_file_name)
  end
  # Retourne le nom du fichier ERB qui sera construit à partir du fichier
  # fourni.
  # Ce nom possède l'affixe du fichier fourni (auquel on a pu enlever '.c2f')
  # avec l'extension '.erb'
  #   /mon/path/to/fichier.rb => /mon/path/to/fichier.erb
  #   /mon/path/to/fichier.c2f.rb => /mon/path/to/fichier.erb
  def erb_file_name
    @erb_file_name ||= begin
      affixe = File.basename(path,File.extname(path))
      if File.extname(affixe) === '.c2f' || File.extname(affixe) === '.f2c'
        affixe = File.basename(affixe, File.extname(affixe))
      end
      "#{affixe}.erb"
    end
  end


  # ---------------------------------------------------------------------

  class Line
    attr_reader :f2c
    attr_reader :indentation, :code, :tag
    attr_reader :first_word, :attributes, :text
    def initialize f2c, indent, code
      @f2c = f2c
      @indentation  = indent
      @code         = code
    end

    def to_html
      decompose_line
      finalise_code
      "\n#{indent_str}#{opened_tag}"
    end

    # La balise d'ouverture complète, avec le texte, en fonction de la ligne
    # Elle peut se définir ici (lorsqu'elle est "normale") ou ailleurs, lorsqu'il
    # faut ajouter des champs, comme dans un checkbox par exemple
    def opened_tag
      @opened_tag ||= "#{String.opened_tag(tag, attributes)}#{text}"
    end

    # La balise de fermeture, en fonction de la ligne
    def closed_tag
      case tag
      when 'input', 'checkbox' then "\n"
      when 'span', 'a', 'legend' then "</#{tag}>" # pas de retour chariot
      else "\n#{indent_str}</#{tag}>"
      end
    end

    def decompose_line
      get_attributes
      @first_word = words.first.downcase
      @tag        = define_tag
    end

    # Quelques corrections juste avant de retourner le code HTML
    def finalise_code
      # La légende, qui doit être dans une style 'font-variant: small-caps'
      # doit être mis en minuscule.
      @text = @text.downcase if @text && tag === 'legend'
    end

    def define_tag
      case first_word
      when 'form'
        if attributes[:protected]
          @attributes.delete(:protected)
          @opened_tag = build_protected_form_from_line
        end
        'form'
      when 'main_div'
        add_class 'main'
        'div'
      when 'small_div'
        add_class 'small'
        'div'
      when 'tiny_div'
        add_class 'tiny'
        'div'
      when 'buttons'
        add_class 'row buttons'
        'div'
      when 'left'
        add_class 'fleft'
        'div'
      when 'submit'
        add_attribute(type:'submit', value:text)
        @text = nil
        'input'
      when 'checkbox'
        # S'il y a un :label ou un :text, il faut créer un label
        if @text
          @opened_tag = build_checkbox_from_line
          'checkbox' # pour ne rien mettre à la fermeture
        else
          add_attribute type: 'checkbox'
          'input'
        end
      else
        first_word
      end
    end

    # Pour construire un formulaire protégé
    def build_protected_form_from_line
      "<% app.checkform_on_submit %>#{RC}" +
      String.opened_tag('form', attributes) + RC +
      "<%= app.checkform_hidden_field('#{attributes[:id]}') %>#{RC}"
    end

    def build_checkbox_from_line
      label = @text
      @text = nil
      # Si le CB ne définit pas d'identifiant, il faut lui en donnant un
      @attributes[:id] ||= @attributes[:name].gsub(/[\[\(]/,'_').gsub(/[\]\)]/,'')
      (
        ''.in_input(attributes.merge(type:'checkbox')) +
        label.in_label(for: attributes[:id])
      ).in_div(id:"cb_container-#{attributes[:id]}", class:'cb_container')
    end

    def indent_str
      @indent_str ||= ('  '*indentation)
    end
    def add_class newCss
      @attributes ||= {}
      @attributes.key?(:class) || @attributes.merge!(class: [])
      @attributes[:class] << newCss
    end
    def add_attribute h
      @attributes ||= {}
      @attributes.merge!(h)
    end

    # Analyse la ligne hors du premier mot
    # ------------------------------------
    def get_attributes # de la ligne de code
      @attributes ||= {}
      attrs = {}
      words[1..-1].each do |word|
        case word
        when /^(['"])(.+?)\1$/ # <= c'est un string seul => c'est le contenu textuel
          # debug "STR = #{word.inspect}"
          @text = as_string_value(word)
        when /:/
          a, v = word.split(':')
          # debug "str = #{v.inspect}"
          @attributes.merge!(a.to_sym => as_string_value(v))
        else
          raise "Le mot '#{word}' est mal formaté dans la ligne \"#{code}\". Je ne peux pas traiter ce code"
        end
      end
      # puts "@attributes: #{@attributes.inspect}"
    end
    def words
      @words ||= code.split(' ')
    end

    # Méthode de transformation des valeurs string, qui sont entourées de
    # guillemets (simples ou doubles) et peuvent contenir des espaces qui
    # ont été remplacées.
    #
    # Si la valeur n'est pas entourée de guillemets simples ou doubles,
    # c'est une valeur à évaluer tout de suite.
    #
    def as_string_value str
      case str
      when 'true'   then true
      when 'false'  then false
      when 'nil'    then nil
      else
        if str.match(/^['"]/) && str.match(/['"]$/)
          str = str.gsub(/__SP__/,' ')
          str = str.gsub(/^['"]/,'').gsub(/['"]$/,'')
        else
          debug "Méthode à évaluer : #{str}"
          str = f2c.owner.send(str.to_sym)
        end
        str
      end
    end

  end #/Line

end #/FormToCode
