# encoding: UTF-8
class String

  class << self

    def base_application
      @base_application ||= begin
        File.expand_path '.'
      end
    end
    def reg_base_application
      @reg_base_application ||= begin
        /#{Regexp::escape base_application}/
      end
    end

  end # << self

  # Prend une liste de chiffres séparés par des espaces, p.e. "1 2 65 6"
  # et retourne une liste d'entier (p.e. [1, 2, 65, 6])
  def as_list_num_with_spaces
    if self.nil_if_empty.nil?
      []
    else
      self.split(' ').collect{|n| n.to_i }
    end
  end


  # Changer un bit dans le texte, en l'allongeant si
  # nécessaire
  # TODO Implémenter la méthode set_bit!
  #
  # +ibit+ Indice du bit à modifier
  # +valbit+ Valeur à donner au bit +ibit+ (0-start)
  #
  def set_bit ibit, valbit
    opts = self.split('')
    opts[ibit] = valbit
    opts.collect{|e| e.to_i}.join('')
  end

  # Par exemple, lorsqu'un argument de fonction peut être
  # un array ou un string, cette méthode permet de ne pas
  # avoir à tester si l'élément est un array ou non.
  def in_array
    [self]
  end

  # Retire toutes les balises du string
  #
  # +separator+ Texte de remplacement pour chaque balise
  # Penser que ces balises sont aussi les italiques et
  # autres marques de formatage.
  def strip_tags separator = ''
    str = self
    str = str.gsub(/<(.+?)>/, separator)
    str.gsub!(/<adminonly>(.*?)<\/adminonly>/,'')
    return str
  end

  # Renvoie le nombre de pages dans self après la
  # suppression de toutes les balises HTML et en considérant
  # qu'il y a +signes_per_page+ signes par page
  def nombre_pages signes_per_page = 1500, options = nil
    (self.gsub(/<%=(.*?)%>/,'\\1').strip_tags.length.to_f / signes_per_page).round(2)
  end

  # Renvoie le nombre de signes dans le self après la
  # suppression de toutes les balises HTML
  #
  # Pour les code ERB qui retourne quelque chose à marquer,
  # on met un texte fictif.
  def nombre_signes
    self.gsub(/<%=(.*?)%>/,'\\1').strip_tags.length
  end

  # ---------------------------------------------------------------------

  # Pour "épurer" le string, c'est-à-dire :
  #   - le striper
  #   - remplacer les apostrophes double par des ' “ ' (courbe double)
  def purified
    str = self
    str = str.strip
    str = str.gsub(/\r/, '') if str.match(/\n/)
    str.gsub(/"(.*?)"/, '“\1”')
  end

  # Met le texte +searched+ en exergue dans le self.
  # C'est-à-dire que tous les textes sont mis dans des
  # span de class `motex` (mot-exergue)
  #
  # La méthode met également le nombre d'itérations
  # remplacées dans @iterations_motex qu'on peut obtenir
  # à l'aide de String#instance_variable_get('@iterations_motex')
  #
  # +searched+
  #     {String}  L'expression exacte à chercher
  #     {Regexp}  L'expression régulière à évaluer sur self
  #     {Hash}    Hash définissant la recherche.
  #               {:content, :exact, :whole_word, :not_regular}
  #
  # Voir le fichier ./__Dev__/__RefBook_Utilisation__/Vues/Textes.md
  # pour le détail.
  #
  def with_exergue searched
    if searched.instance_of?( Hash )

      is_exact        = searched[:exact]        || false
      is_whole_word   = searched[:whole_word]   || false
      is_not_regular  = searched[:not_regular]  || false
      is_regular      = !is_not_regular

      reg = "#{searched[:content]}"
      reg = Regexp::escape( reg ) if is_not_regular

      searched = case true
      when !(is_exact || is_regular || is_whole_word) then /(#{reg})/
      when !is_exact && !is_whole_word  then /(#{reg})/i
      when !is_exact && is_whole_word   then /\b(#{reg})\b/i
      when is_whole_word                then /\b(#{reg})\b/
      else /(#{reg})/
      end
    else
      searched = /(#{searched})/
    end
    str = self.gsub(searched, "<span class='motex'>\\1</span>")
    str.instance_variable_set('@iterations_motex', self.scan(searched).count)
    return str
  end

  # {Fixnum} Quand le string est une horloge, la transforme en
  # secondes
  def h2s
    str = self.split(':').reverse
    str[0].to_i + str[1].to_i * 60 + str[2].to_i * 3600
  end

  # Pour upcaser vraiment tous les caractères, même les accents et
  # les diacritiques
  DATA_MIN_TO_MAJ = {
    from: "àäéèêëîïùôöç",
    to:   "ÀÄÉÈÊËÎÏÙÔÖÇ"
  }
  alias :old_upcase :upcase
  def upcase
    self.old_upcase.tr(DATA_MIN_TO_MAJ[:from], DATA_MIN_TO_MAJ[:to])
  end

  alias :old_downcase :downcase
  def downcase
    self.old_downcase.tr(DATA_MIN_TO_MAJ[:to], DATA_MIN_TO_MAJ[:from])
  end

  def nil_if_empty strip = true
    checked = strip ? self.strip : self
    checked == "" ? nil : checked
  end
  def nil_or_empty?
    self.strip == ""
  end

  # La méthode deserb retourne le code self ou le code du fichier self
  # déserbé.
  def deserb bindee = nil
    code =
      if File.exist?(self)
        File.read(self)
      else
        self
      end.force_encoding('utf-8')
    ERB.new(code).result(bindee)
  end

  ##
  # Transforme une path absolue en path relative
  #
  # NOTE
  #
  #   * Si la classe App existe et définit la méthode
  #     de classe `relative_path_of', on l'utilise, sinon, on
  #     calcul la "base" de l'application.
  #
  def as_relative_path
    if defined?(App) && App.respond_to?( :relative_path_of)
      App::relative_path_of self
    else
      rel_path = self.gsub(String::reg_base_application, '')
      rel_path.prepend(".") unless rel_path.start_with?('.') || (rel_path == self)
      return rel_path
    end
  end


  # Ruby version < 2
  unless "".respond_to?(:prepend)
    def prepend str
      self.replace "#{str}#{self}"
    end
  end

  unless "".respond_to?(:capitalize)
    def capitalize
      s = self
      s[0..0].upcase + s[1..-1]
    end
  end

  def numeric?
    Float(self) != nil rescue false
  end

  # Chamelise ('mon_nom_tiret' => 'MonNomTiret')
  def camelize
    self.split('_').collect{|mot| mot.capitalize}.join("")
  end

  def decamelize
    self.gsub(/(.)([A-Z])/, '\1_\2').downcase
  end

  # Transformer les caractères diacritiques et autres en ASCII
  # simples
  unless defined? DATA_NORMALIZE
    DATA_NORMALIZE = {
      :from => "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
      :to   => "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
    }
  end
  # ou def normalized
  def normalize
    self.force_encoding('utf-8').tr(DATA_NORMALIZE[:from], DATA_NORMALIZE[:to])
  end
  alias :normalized :normalize

  # Pour un nom de fichier sans problème
  def as_normalized_filename
    self.normalize.gsub(/ +/, '_').gsub(/[^a-zA-Z0-9\._]/, '').gsub(/_+/, '_').gsub(/^_/,'').gsub(/_$/,'')
  end

  # Transforme la chaine en “id normalizé”, c'est-à-dire un
  # identifiant de type String, ne contenant que des lettres et
  # des chiffres, avec capitalisation de la première lettre de
  # chaque mot.
  # Par exemple :
  #     "Ça c'est l'été et mon titre" => "CaCestLeteEtMonTitre"
  def as_normalized_id separateur = nil
    separateur ||= ""
    self.normalize.gsub(/[^a-zA-Z0-9 ]/, separateur).downcase.split.collect{|m|m.capitalize}.join(separateur)
  end

  # Retire les slashes
  #
  def strip_slashes
    self.gsub(/\\(['"])/, '\\1')
  end

end
