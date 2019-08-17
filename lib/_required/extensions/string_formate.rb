# encoding: UTF-8

class String

  def formate_balises_erb
    self.gsub(/<%=(.*?)%>/){
      begin
        eval($1.strip)
      rescue Exception => e
        $1
      end
    }
  end

  def formate_balises_propres
    str = self

    # debug "STRING AVANT = #{str.gsub(/</,'&lt;').inspect}"

    str = str.formate_balises_references
    str = str.formate_balises_images
    str = str.formate_balises_mots
    str = str.formate_balises_films
    str = str.formate_balises_scenes
    str = str.formate_balises_livres
    str = str.formate_balises_personnages
    str = str.formate_balises_realisateurs
    str = str.formate_balises_producteurs
    str = str.formate_balises_acteurs
    str = str.formate_balises_auteurs
    str = str.formate_termes_techniques
    str = str.formate_balises_citations

      # debug "STRING APRÈS = #{str.gsub(/</,'&lt;').inspect}"
    return str
  end

  def formate_balises_references
    str = self
    str.gsub!(/REF\[(.*?)\]/){
      pid, ancre, titre = $1.split('|')
      if titre.nil? && ancre != nil
        titre = ancre
        ancre = nil
      end
      lien.cnarration(to: :page, from_book:$narration_book_id, id: pid.to_i, ancre:ancre, titre:titre)
    }
    str
  end

  # Formate les balises images
  #
  # +subfolder+ {String} Un nom de dossier qui peut être transmis
  # parfois pour indiquer un dossier narration ou un dossier
  # d'analyse.
  def formate_balises_images subfolder = nil
    return self unless self.match(/IMAGE\[/)
    self.gsub!(/IMAGE\[(.+?)\]/){
      path, title, legend, expfolder = $1.split('|')
      imgpath = String::seek_image_path_of( path, subfolder || expfolder)
      title  = title.gsub(/'/, "’") unless title.nil?
      if imgpath != nil

        # La légend, if any
        # La légende peut avoir trois valeur :
        #   1. être nil   => Rien
        #   2. être ""    => On prend le titre comme légende
        #   3. être définie comme telle
        legend = case legend
        when "="          then title
        when nil, "null"  then nil
        else legend
        end
        legend = legend.nil? ? "" : "<div class='img_legend'>#{legend}</div>"


        attrs = {}

        # Si `title` se termine par '%', c'est une taille
        # à prendre en compte
        unless (rs = title.scan(/ ?([0-9]{1,3})%$/)).empty?
          taille  = rs.first.first.to_i
          attrs.merge!(style: "width:#{taille}%")
          # Ce qu'il reste du titre
          title   = title.sub(/ ?([0-9]{1,3})%$/, '').strip
        end

        # Soit title est un titre alternatif (qui pourra
        # servir de légende si légende non définie) ou bien
        # c'est un indicateur de position de l'image.
        # Le texte construit retourné
        case title
        when 'inline'
          imgpath.in_img( attrs )
        when 'fright', 'fleft'
          attrs.merge!( class:"image_#{title}" )
          (imgpath.in_img + legend).in_div( attrs )
        else
          title =
            if title == 'plain'
              attrs.merge!(style: 'width:100%')
              ""
            else
              " alt=\"Image : #{title}\""
            end
          attrs = attrs.collect { |attr, val| "#{attr}=\"#{val}\"" }.join(' ')
          img_tag = "<img src='#{imgpath}'#{title} #{attrs} />"
          "<center class='image'><div class='image'>#{img_tag}</div>#{legend}</center>"
        end
      else
        "IMAGE MANQUANTE: #{imgpath} (avec #{path} fourni)"
      end

    }
  end

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){
      mot_id = $1.freeze
      mot_mot = $2.freeze
      mot_mot.in_a(href: route_boa("scenodico/#{mot_id}/show"), target: :new)
    }
    str
  end

  def formate_balises_citations
    str = self
    str.gsub!(/CITATION\[([0-9]+)\|(.*?)\]/){
      cit_id = $1.freeze
      cit_titre = $2.freeze
      cit_titre.in_a(href: route_boa("citation/#{cit_id}/show"), target: :new)
    }
    str
  end

  def formate_balises_films
    str = self
    str.gsub!(/FILM\[(.*?)(?:\|(.*?))?\]/){
      film_id = $1.freeze
      film_titre = $2.freeze
      film_titre.in_a(href: route_boa("filmodico/#{film_id}/show"), target: :new)
    }
    str
  end

  def formate_balises_scenes # Analyses
    str = self
    str.gsub!(/SCENE\[(.*?)\]/){
      numero, libelle, extra = $1.split('|').collect{|e| e.strip}
      # Je ne sais plus à quoi sert `extra`, il peut avoir
      # la valeur 'true'
      libelle ||= "scène #{numero}"
      libelle.in_a(onclick:"$.proxy(Scenes,'show',#{numero})()")
    }
    str
  end

  def formate_balises_livres
    str = self
    str.gsub!(/LIVRE\[(.*?)\]/){
      ref, titre = $1.split('|')
      lien.livre(titre, ref)
    }
    str.formate_balises_colon('livre')
  end

  def formate_balises_personnages
    self.formate_balises_colon('personnage')
  end

  def formate_balises_acteurs
    self.formate_balises_colon('acteur')
  end

  def formate_balises_realisateurs
    self.formate_balises_colon('realisateur')
  end

  def formate_balises_producteurs
    self.formate_balises_colon('producteur')
  end

  def formate_balises_auteurs
    self.formate_balises_colon('auteur')
  end

  def formate_termes_techniques
    self.formate_balises_colon('tt')
  end

  def formate_balises_colon balise
    str = self
    str.gsub!(/#{balise}:\|(.*?)\|/, "<#{balise}>\\1</#{balise}>")
    str.gsub!(/#{balise}:(.+?)\b/, "<#{balise}>\\1</#{balise}>")
    str
  end


  # Méthodes utiles pour trouver comment interpréter
  # le path (relatif) fourni en argument pour une
  # balise IMAGE
  #
  # Cf. aide
  #
  # Dans l'ordre, le path relatif peut être :
  #
  #   - Un path depuis la racine (on le garde tel quel)
  #   - Un path depuis le dossier général ./view/img/
  #   - Un path depuis le dossier img général Narration
  #     ./data/unan/pages_semidyn/cnarration/img
  #   - Un path depuis un dossier img d'un livre Narration
  #     Le folder doit alors être fourni en argument
  #   - Un path depuis le dossier img général Analyse
  #     ./data/analyse/image
  #   - Un path depuis le dossier img d'une analyse en particulier
  #     Le `folder` doit alors être fourni en 2nd argument
  #
  def self.seek_image_path_of relpath, folder = nil
    [
      '',
      './view/img/',
      "./data/unan/pages_semidyn/cnarration/img/",
      "./data/unan/pages_semidyn/cnarration/#{folder}/img/",
      "./data/unan/pages_semidyn/cnarration/img/#{folder}/",
      "./data/analyse/image/",
      "./data/analyse/#{folder}/img/",
      "#{folder}" # narration ou autre
    ].each do |prefix_path|
      goodpath = "#{prefix_path}#{relpath}"
      return goodpath if File.exist? goodpath
    end
    return nil
  end

end #/String
