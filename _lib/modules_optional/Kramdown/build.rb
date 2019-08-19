# encoding: UTF-8
=begin

Extension de la class SuperFile pour traiter un code markdown
avec Kramdown.

@usage

  site.require_module('Kramdown')

  <superfile>.kramdown[ <{options}>]

  # => Retourne le code transformé SAUF si :in_file est défini, qui
  # doit définir le path du fichier dans lequel écrire le code

=end

site.require_deeper_gem "kramdown-1.9.0"

class ::String
  DATA_OUTPUT_FORMAT = {
    :html   => {extension: '.html'},
    :latex  => {extension: ".tex" },
    :pdf    => {extension: '.tex'}, # car il faut passer par là avant
    :erb    => {extension: ".erb"}
  }

  # Kramdownise un string c'est-à-dire prend un code au format
  # markdown et le transforme en un autre code
  #
  # +options+
  #     :output_format:
  #         Format de sortie du code (HTML par défaut)
  #
  #     :owner    DONNÉE TRÈS IMPORTANTE qui détermine par exemple
  #               si le code vient d'un SuperFile. Dans ce cas, ce
  #               possesseur peut déterminer des méthodes supplémentaires
  #               de traitement
  #     :folder_image   Le dossier des images
  #     :pre_code Du code markdown à ajouter avant le code
  #
  def kramdown options = nil

    options ||= Hash.new
    options[:output_format] = :html unless options.key?(:output_format)

    owner = options[:owner]

    # La méthode de transformation, suivant le format
    # de sortie voulu
    mdown_method =
      case options[:output_format]
      when :html, :erb then :to_html
      when :latex      then :to_latex
      when :pdf        then :to_latex
      end

    # Pour extra_markdown par exemple
    output_format =
      case options[:output_format]
      when :html, :erb  then :html
      when :latex       then :latex
      when :pdf         then :latex
      end

    code = self

    # Au format LaTex, quelques corrections obligées
    if output_format == :latex
      code.gsub!(/ /, '&nbsp;') # insécables
    end

    # Si le format de sortie est de l'ERB, il faut protéger les
    # balises ERB sinon, kramdown transformerait les pourcentages en
    # signe pourcentage.
    # Si le format n'est pas de l'ERB, mais qu'il existe des balises
    # ERB dans le document (comme dans ma version markdown) alors
    # il faut évaluer ce code avant de passer à la suite
    if options[:output_format] == :erb
      code = code.gsub(/<\%/,'ERBtag').gsub(/\%>/,'gatBRE')
    elsif code.match(/<\%/)
      code = code.gsub(/<\%(= )?(.+?)\%>/){
        egal = $1.freeze
        code = $2
        code = code.strip.freeze rescue nil
        begin
          res = eval(code)
        rescue Exception => e
          debug e
          "# ERREUR EN ÉVALUANT : #{code} : #{e.message}"
        else
          if egal != nil
            res
          else
            # Simple évaluation du code (mais pour le moment, je
            # ne pense pas que ça serve à grand chose…)
            ""
          end
        end
      }
    end

    # Si le code contient "\nDOC/" c'est que des documents sont
    # définis dans le code, on les traite avant tout autre
    # traitement
    code = code.mef_document if code.match(/\nDOC\//)

    # Si une méthode de traitement des images existe,
    # il faut l'appeler.
    # Noter qu'il faut appeler cette méthode AVANT la
    # suivante, car la suivante traite aussi les balises
    # IMAGE mais de façon plus générale (et sans pouvoir
    # définir des sous-dossiers).
    code = code.formate_balises_images(options[:folder_image]) if self.respond_to?(:formate_balises_images)

    # Si une méthode formate_balises_propres existe, il
    # faut l'appeler sur le code pour les transformer
    code = code.formate_balises_propres if self.respond_to?(:formate_balises_propres)

    # Si une méthode de traitement additionnel existe,
    # il faut lui envoyer le code
    if owner && owner.respond_to?(:formatages_additionnels)
      code = owner.formatages_additionnels(code, options)
    end

    # Traitement extra kramdown
    # TODO: Dans l'idéal, il faudrait apprendre à les insérer
    # dans le traitement Kramdown::Document ci-dessous…
    code = ( code.extra_kramdown output_format )

    #
    # = MAIN TRAITEMENT MARKDOWN (KRAMDOWN) =
    #

    # debug "\n\ncode AVANT kramdown : #{code.gsub(/</,'&lt;').inspect} \n\n"

    # Pour une raison inconnue mais qui doit être propre à Kramdown,
    # les balises <personnages>...</personnages> en début de ligne
    # sont toujours agrémentées d'un <p> derrière après traitement par
    # kramdown.
    # Il faut donc, ci-dessous, "protéger" ces balises puis les
    # remettre après le kramdownage.
    # Note : J'ai essayé de changer les options de Kramdown mais ça
    # n'a rien changé. Dans l'idéal je pense qu'il ne faudrait pas
    # du tout de balise HTML avant de kramdowner.
    code.gsub!(/<personnage>(.+?)<\/personnage>/, 'PERStag\1gatSREP')

    # Si c'est une transformation vers LaTex,
    # on protège les accolades et les backslaches qui
    # correspondent à des commandes (\commande{...})
    if output_format == :latex
      code.gsub!(/\\([a-zA-Z\*]+?)(?:\[(.+?)\])?\{(.*?)\}/){
        commande    = $1.freeze
        parameters  = $2.freeze
        arguments   = $3.freeze
        parameters = parameters.nil? ? "" : "PARS--#{parameters}--SRAP"
        "PROTECTEDBACKSLASHES#{commande}#{parameters}ACCO--#{arguments}--OCCA"
      }
    end

    # === KRAMDOWNAGE ===
    kramdown_options = {
      header_offset:    0, # pour que '#' fasse un chapter
      # Ordre (6 valeurs obligatoires)
      latex_headers:  ['chapter','section','subsection','subsubsection','paragraph','subparagraph']
    }
    code_final = Kramdown::Document.new(code, kramdown_options).send(mdown_method)


    # Déprotéger ce qui a été protégé avant Kramdown
    if output_format == :latex
      code_final = code_final.
          gsub(/PROTECTEDBACKSLASHES/, "\\").
          gsub(/ACCO--/,'{').gsub(/--OCCA/,'}').
          gsub(/PARS--/,'[').gsub(/--SRAP/,']')
    end
    code_final.gsub!(/PERStag(.+?)gatSREP/,'<personnage>\1</personnage>')

    # debug "\n\ncode APRÈS kramdown : #{code_final.gsub(/</,'&lt;').inspect} \n\n"

    if code_final.match(/ERBtag/)
      if options[:output_format] == :erb
        code_final = code_final.gsub(/ERBtag/,'<%').gsub(/gatBRE/,'%>')
      else
        # Si la sortie n'est pas en :erb, il faut interpréter
        # le code
        code_final.gsub!(/ERBtag(.+?)gatBRE/){
          begin
            c = $1
            c = c[1..-1].string if c.start_with?('=')
            eval c
          rescue Exception => e
            debug e
            "[ERREUR EN INTERPRÉTANT `#{c}` : #{e.message}]"
          end
        }
      end
    end

    return code_final
  end

end

class SuperFile

  DATA_OUTPUT_FORMAT = String::DATA_OUTPUT_FORMAT

  # Dossier contenant les bin pdflatex, etc.
  # Attention, ça ne fonctionnera pas sur le site distant
  TEXLIVE_FOLDER = "/usr/local/texlive/2015/bin/x86_64-darwin/"

  # Retourne le code du fichier, kramdowné
  #
  # :alias: def as_kramdown
  #
  # +options+
  #     Cf. la méthode String#kramdown ci-dessus
  #     + autres propriétés :
  #       :in_file    Si fourni, c'est un path dans lequel le code
  #                   transformé sera enregistré. Sinon, le code est
  #                   simplement retourné.
  #                   Ça peut être un SuperFile
  #
  #       :pre_code   Code Markdown à ajouter avant le code du
  #                   fichier. Par exemple pour définir des définitions
  #                   de liens.
  #
  def kramdown options = nil
    options ||= Hash.new

    # On doit produire un code ERB
    options[:output_format] ||= :erb

    # Le dossier contenant les images
    # Soit une méthode existe (extension de la classe SuperFile, comme
    # pour la collection Narration), soit on prend le dossier du fichier
    dossier_des_images =
      if self.respond_to?(:folder_image)
        folder_image
      else
        folder.to_s
      end

    options.merge!(
      owner:        self,
      # Pour trouver un dossier image, if any
      folder_image: dossier_des_images
    )

    code = self.read.gsub(/\r\n?/, "\n").chomp

    code = options[:pre_code] + code if options[:pre_code]

    # ATTENTION, ÇA NE FONCTIONNE QUE SI ON LANCE LE SCRIPT
    # TEXTMATE
    # STDOUT.write( code )

    code_final = code.kramdown(options)

    if options[:in_file]
      # Écrire le code dans ce fichier
      dest_path =
        case options[:in_file]
        when String, SuperFile then options[:in_file]
        when TrueClass  then (self.folder + self.affixe).to_s
        end
      if File.extname(dest_path.to_s) == ""
        dest_path += DATA_OUTPUT_FORMAT[options[:output_format]][:extension]
      end
      dest_path = SuperFile::new(dest_path) unless dest_path.instance_of?(SuperFile)
      dest_path.write code_final
    end

    # Sortie en PDF
    # Un fichier latex a été construit, il faut maintenant le
    # transformer en fichier PDF.
    #
    # Le fichier LaTex se trouve dans `dest_path`
    if options[:output_format] == :pdf
      Dir.chdir(self.folder) do
        `#{TEXLIVE_FOLDER}pdflatex #{self.affixe}.tex`
        # Si index
        # `#{TEXLIVE_FOLDER}makeindex main.idx`
        # `#{TEXLIVE_FOLDER}pdflatex #{self.affixe}`
      end
      flash "Sortie PDF voulue"
    end
    # Retourner ce code dans tous les cas
    return code_final
  end
  alias :as_kramdown :kramdown


end
