# encoding: UTF-8
class Lien
  include Singleton

  attr_reader :all_link_to_distant

  # Pour définir que tous les liens doivent être produits
  # comme des liens distants. Cela permet, par exemple, de ne pas
  # se soucier d'avoir mis l'argument online: true dans les liens pour
  # les mails.
  # Usage :
  #     lien.all_link_to_distant= true
  #     ... opération utilisant les liens, par exemple send_mail ...
  #     lien.all_link_to_distant= nil # réinitialisation
  #
  def all_link_to_distant= value
    @all_link_to_distant = value
  end

  # Pour définir le format de sortie général.
  # Utilisé par l'export en LaTex de la collection Narration
  # Utilisé par la construction du manuel (Markdown) d'utilisation
  # du programme ÉCRIRE UN FILM/ROMAN EN UN AN.
  #
  attr_writer :output_format
  def output_format
    @output_format || :html
  end

  # Méthode principale permettant de construire un lien
  # quelconque, pour éviter de répéter toujours le même code
  # +options+
  #   :distant    Si true, on transforme la route en URL complète
  #   :arrow_cadre  Un type de lien avec flèche et cadre
  # NOTES
  #   - Par défaut, le lien s'ouvre dans une nouvelle fenêtre.
  #     ajouter options[:target] = nil pour empêcher ce comportement
  def build route, titre, options
    options ||= {}

    type_lien = options.delete(:type)
    is_arrow_cadred = type_lien == :arrow_cadre

    distant_link = options.delete(:distant) || options.delete(:online) || all_link_to_distant

    distant_link && route = "#{site.distant_url}/#{route}"
    case output_format
    when :latex
      # TODO améliorer les choses ensuite
      titre
    when :markdown
      # En markdown, on a deux solutions : si le titre est fourni,
      # on retourne un lien complet [titre](liens){... options ....}
      # Sinon, on ne retourne que l'url, sans les parenthèses
      if titre == nil
        route
      else
        options = options.collect{|k,v| "{:#{k}=\"#{v}\"}"}.join('')
        "[#{titre}](#{route})#{options}"
      end
    else
      options.merge!(href: route)
      options.key?(:target) || options.merge!(target:'_blank')
      if is_arrow_cadred
        titre = titre.in_span(class:'cadre')
        "#{ARROW}#{titre}".in_a(options)
      else
        titre.in_a(options)
      end
    end
  end

  def home titre = "Accueil", options = nil
    build('site/home', titre, options)
  end

  # Lien vers la section de contact du site
  def contact titre = "Contact", options = nil
    build('site/contact', titre, options)
  end

  # Retourne les boutons avant et après uniformisés
  #
  # +args+  Doit au moins contenir :
  #         :href/route       L'URL pour rejoindre la page précédente
  #
  # Ces boutons sont placés dans un div.nav. On peut se servir de
  # l'attribut :class pour redéfinir la classe de ce div (qui gardera
  # cependant toujours la class 'nav')
  #
  def backward_button args
    args = normalize_args_buttons args
    "←".in_a(href: args[:href]).in_div(style: args[:style], class: args[:class])
  end
  alias :bouton_backward :backward_button
  def forward_button args
    args = normalize_args_buttons( args )
    "→".in_a(href: args[:href]).in_div(style: args[:style], class: args[:class])
  end
  alias :bouton_forward :forward_button

  def normalize_args_buttons args
    # Style
    style = Array.new
    is_visible = args.key?(:visible) ? args[:visible] : true
    args.key?(:visible) && style << "visibility:#{args[:visible] ? 'visible' : 'hidden'}"
    args.key?(:style)   && style << args[:style]

    args[:style] =
      case true
      when style.empty? then nil
      else style.join(';')
      end

    # Class CSS
    classe = ['nav']
    args.key?(:class) && classe << args[:class]
    args[:class] = classe.join(' ')

    return args
  end

  # Retourne un lien qui est l'image du point d'interrogation
  # conduisant à un fichier d'aide d'ID +aide_id+
  #
  # Par défaut, les liens s'ouvrent toujours dans une nouvelle
  # fenêtre.
  #
  # @usage      lien.aide(xxx[, options])
  # @usage      lien.information(xxx[, options])
  #
  # +aide_id+   SI {Integer} Identifiant du fichier d'aide, correspondant
  #             au fichier dans le dossier ./_objet/aide/lib/data/texte
  #             SI {String}, le titre pour rejoindre l'aide du site
  # +options+   {Hash|String} Options définissant le lien
  #             OU le texte du lien lui-meême.
  #     :discret      Si false, le lien d'aide ne sera pas "discret"
  #                   (true par défaut)
  #
  def aide aide_id, options = nil

    if aide_id.instance_of?(String)
      return build( "aide/home", aide_id, options)
    end

    options ||= Hash.new
    options = {titre: options} if options.instance_of?(String)
    options.key?(:titre) || options.merge!(titre: image('pictos/picto_info_dark.png'))
    unless options.key?(:class)
      options[:class] ||= ''
      options[:class] << ' lkaide'
      options.delete(:discret) === false || options[:class] << 'discret'
      options[:class] = options[:class].strip
    end
    options.key?(:target) || options[:target] = '_blank'
    options.merge!(
      href:   "aide/#{aide_id}/show",
      class:  options[:class]
    )
    options.delete(:titre).in_a(options)
  end
  alias :information :aide

  # Similaire à `build` mais avec un nom plus parlant et l'ordre
  # est celui de Markdown. Les arguments sont également plus
  # souples :
  #   - si les deux premiers arguments sont des strings, c'est le
  #     titre et la route
  #   - si le second argument est un Hash, le premier est la route,
  #     c'est-à-dire que le titre n'est pas fourni (on ne veut par
  #     exemple qu'obtenir un href distant)
  #   - s'il n'y a qu'un seul argument, c'est la route
  #
  # Si lien.output_format est :markdown, et que le titre est défini,
  # la méthode retourne un texte de la forme "[titre](lien){...options...}"
  # Sinon, retourne simplement le "lien" sans les parenthèses.
  # Mettre en options {distant: true} pour obtenir un lien vers le site
  # distant.
  def route titre, route = nil, options = nil
    case true
    when route.nil? && options.nil? then
      route = titre.dup.freeze
      titre = nil
    when options.nil? && route.instance_of?(Hash)
      options = route.dup
      route   = titre.dup.freeze
      titre   = nil
    end
    build route, titre, options
  end

  # Lien pour s'inscrire sur le site
  def signup titre = "s'inscrire", options = nil
    build "user/signup", titre, options
  end
  alias :inscription :signup

  # Lien pour s'identifier
  def signin titre = "s'identifier", options = nil
    options ||= Hash.new
    href = "user/signin"
    href += "?backto=#{CGI::escape(options.delete(:back_to))}" if options.key?(:back_to)
    build href, titre, options
  end

  def subscribe titre = "s'abonner", options = nil
    options ||= Hash.new
    options.merge!(query_string:"user[subscribe]=on")
    build "user/paiement", titre, options
  end
  alias :sabonner   :subscribe
  alias :abonnement :subscribe

  # +options+
  #   :visible    Si true, le bouton ne sera pas discret
  #   :align      Si défini, position du bouton, qui peut être
  #               :left, :right ou :center
  #   :filled     Si true, le bouton est vert avec le texte en
  #               blanc (donc très visible)
  def bouton_subscribe options = nil
    # type: :arrow_cadre
    options ||= {}
    options.key?(:tarif) || options.merge!(tarif: true)
    options.key?(:align) || options.merge!(align: 'right')

    css_bouton = ['cadre']
    options[:filled] && css_bouton << 'bgvert'

    options[:titre] ||= begin
      tarif = options[:tarif] ? "<br>(pour #{site.tarif_humain}/an)".in_span(class:'tiny') : ''
      (
        "#{ARROW} S'ABONNER" + tarif
      ).in_div(class: css_bouton.join(' '), style:'display:inline-block;line-height:0.6em;width:136px;')
    end
    css = ['small vert']
    options[:visible] || css << 'discret'
    css_div = [options[:align].to_s]
    subscribe(options[:titre], class: css.join(' ')).in_div(class: css_div.join(' '))
  end
  alias :bouton_abonnement :bouton_subscribe

  # Pour rejoindre la console
  def console titre = "console", options = nil
    raise_unless_admin
    build 'admin/console', titre, options
  end

  # Obtenir un lien pour l'édition du fichier de path +path+
  # qui peut être aussi bien un chemin relatif qu'un chemin complet.
  # Le contenu du fichier est édité par l'éditeur du site, qui doit être
  # réservé à l'administrateur
  def edit_text path, options = nil
    options ||= Hash.new
    titre = options.delete(:titre) || "Édition du contenu de `#{path}'"
    fullpath = File.expand_path(path)
    options.merge!(href: "site/edit_text?path=#{fullpath}")
    options.key?(:target) || options.merge!(target: :new)
    titre.in_a(options)
  end

  # Lien pour éditer un fichier par son path, dans l'éditeur de
  # son choix, soit Textmate, soit Atom si le fichier est d'extension
  # quelconque, sauf .md
  # Les fichiers Markdown sont ouverts par l'application "MarkdownLife"
  # si c'est réglé dans le fichier configuration
  def edit_file path, options = nil
    options ||= Hash.new
    editor  = options.delete(:editor) || site.default_editor || :atom
    titre   = options.delete(:titre) || "Ouvrir"
    line    = options.delete(:line)

    url =
      case File.extname(path)
      when '.md'
        "site/open_file?path=#{path}" if user.admin?
      when '.pdf'
        "site/open_file?path=#{path}"
      else
        case editor
        when :atom
          "atm://open?url=file://#{path}"
        when :textmate
          "site/open_file?path=#{path}"
          # "txmt://open/?url=file://#{path}"
        else
          "site/open_file?path=#{path}&app=#{editor}"
        end
        # On compose le lien et on le renvoie
      end
    url += "&line=#{line}" unless line.nil?
    build( url, titre, options )
  end

  def forum titre = "le forum", options = nil
    build('forum/home', titre, options)
  end

end

def lien ; @lien ||= Lien.instance end
