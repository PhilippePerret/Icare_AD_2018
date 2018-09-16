# encoding: UTF-8
=begin

  Méthodes pour les formulaires

    User#remplit_le_formulaire(<form ref>).avec(<data>).et_le_soumet
    User#remplit_et_soumet_le_formulaire(<form ref>).avec(<data>)

=end
class User
  include RSpec::Matchers
  include Capybara::DSL
  include RSpecHtmlMatchers

  def scroll_to jid
    cpage.execute_script("UI.scrollTo('#{jid}')")
    sleep 0.75
  rescue Exception => e
    puts "# ERREUR MINEURE dans scroll_to(#{jid.inspect}) : #{e.message}"
  end

  def cpage
    Capybara.current_session
  end

  def remplit_le_formulaire(form)
    form =
      case form
      when String then page.find("form##{form}")
      else form
      end
    FormTest.new(form)
  end

  def clique_le_lien ref_bouton, options = nil
    options ||= Hash.new
    options.key?(:dans) && options.merge!(in: options.delete(:dans))
    if options.key?(:in)
      scroll_to options[:in]
      within(options[:in]){ click_link ref_bouton, match: :first }
    else
      click_link(ref_bouton, match: :first)
    end
  end
  alias :click_le_lien :clique_le_lien

  def coche_la_checkbox  ref_cb, options = nil
    options ||= Hash.new
    options.key?(:dans) && options.merge!(in: options.delete(:dans))
    if options.key?(:in)
      scroll_to options[:in]
      within(options[:in]){ check ref_cb, match: :first }
    else
      check(ref_bouton, match: :first)
    end
  end
  alias :coche_le_checkbox :coche_la_checkbox

  def clique_le_bouton ref_bouton, options = nil
    options ||= Hash.new
    options.key?(:dans) && options.merge!(in: options.delete(:dans))
    container = options[:in]
    if container
      scroll_to container
      if cpage.has_css?("#{container} input[type=\"button\"][value=\"#{ref_bouton}\"]")
        cpage.find("#{container} input[type=\"button\"][value=\"#{ref_bouton}\"]").click
      elsif cpage.has_css?("#{container} input[type=\"submit\"][value=\"#{ref_bouton}\"]")
        cpage.find("#{container} input[type=\"submit\"][value=\"#{ref_bouton}\"]").click
      else
        raise "Impossible de trouver un bouton ou un submit de valeur “#{ref_bouton}”…"
      end
      # within(options[:in]){click_button ref_bouton, match: :first}
    else
      click_button(ref_bouton, match: :first)
    end
  end
  alias :click_le_bouton :clique_le_bouton

  # +args+
  #   Valeurs obligatoires
  #   :with/:avec     La valeur a mettre
  #   :in             ID du formulaire
  #   :qui            La personne qui fait ça.
  #
  def remplit_le_champ ref_field, args
    qui = args.delete(:qui) || "L'user"
    args[:with] ||= args.delete(:avec)
    args[:with] != nil || raise('Il faut définir la valeur à mettre (propriété :with ou :avec)')
    args.key?(:in) || args.key?(:dans) || raise('Il faut définir dans quel formulaire se trouve le champ (propriété :in)')
    args[:in] ||= args.delete(:dans)
    args_init = args.dup
    leform = args.delete(:in)
    leform.start_with?('form#') || leform.start_with?('form.') || leform = "form##{leform}"
    # On procède à l'opération
    scroll_to leform
    # puts "leform    : #{leform}"
    # puts "ref_field : #{ref_field}"
    # puts "args      : #{args.inspect}"
    within(leform){ fill_in( ref_field, args) }
    # Il faut toujours sortir du champ, dans le cas où c'est un
    # textarea qui s'ouvre en grand en bloquant la page
    # 3.times{cpage.execute_script("$('textarea').blur()")}
    cpage.execute_script("$('textarea').blur()")
    @args = args_init
  end

  def attache_le_fichier path_fichier, args
    path_fichier = File.expand_path(path_fichier)
    File.exist?(path_fichier)       || raise("Le document `#{path_fichier}` est introuvable…")
    !File.directory?(path_fichier)  || raise("Le document `#{path_fichier}` est un dossier…")
    to_field  = args.delete(:a)     || args.delete(:to)
    dans      = args.delete(:in)    || args.delete(:dans) || 'body'
    within(dans) do
      attach_file to_field, path_fichier
    end
  end
  def choisit_le_menu val_menu, args
    dans = args.delete(:in) || args.delete(:dans)
    from_select = args.delete(:from) || args.delete(:du_select)
    from_select.nil? || begin
      failure "Dans la tournure `User choisit le menu ...', il vaut mieux ne pas employer :from et définir précisément le select dans :in ou :dans (:in = 'form select'). Je considère que c'est l'identifiant du select qui a été transmis."
      dans ||= ""
      dans << " select##{from_select}"
      dans = dans.strip
    end
    if dans
      dans_arr  = dans.split(' ');
      id_menu   = dans_arr.pop.split('#')[1];
      container = dans_arr.join(' ')
      scroll_to container
      nombre = page.all("#{dans} option").count
      if nombre > 0
        page.all("#{dans} option").each do |node|
          # puts "node.text: #{node.text.inspect} / node.value: #{node.value.inspect} / val_menu : #{val_menu.inspect}"
          if node.text == val_menu || node.value == val_menu
            node.select_option
            break
          end
        end
      else
        # Nombre d'options = 0 (alors qu'il y en a parfois)
        # => on essai par le moyen traditionnel
        within(container) do
          select val_menu, from: id_menu
        end
      end
    else
      select(val_menu)
    end
  end
end

# Retourne l'instance FormTest du formulaire +form+
# +form+ Formulaire obtenu par `page.find('form#...')`
#
# Permet d'utiliser des méthodes comme :
#
#   #a_le_bouton_soumettre('<nom>'[, options])
def le_formulaire form
  FormTest.new(form)
end

class FormTest

  include Capybara::DSL

  #
  attr_reader :form

  attr_reader :resultat

  # Référence au formulaire, par exemple '#identifiant' (meilleure
  # référence)
  attr_reader :ref
  def initialize form, options = nil
    @form     = form
    @options  = options
  end

  def form_id
    @form_id ||= form[:id]
  end

  # Les données avec lesquelles il faut remplir le formulaire
  #
  # +dform+ Les données du formulaire, avec en clé l'identifiant
  # du champ (ou seulement son suffixe — cf. ci-dessous) et en
  # value un Hash définissant :type (le type du champ, :text par
  # défaut) et :value (la valeur à donner au champ)
  # +dform+ peut définir :_prefix qui servira de préfixe à TOUTES les
  # clés
  def avec dform
    # On remplit le formulaire avec les valeurs données
    _prefix = dform.delete(:_prefix) || ''
    dform.each do |field_ref, field_value|
      field_value =
        case field_value
        when String         then {value: field_value}
        when Fixnum, Float  then {value: field_value.to_s}
        when Hash           then field_value
        else raise 'La donnée d’un champ pour remplir un formulaire devrait être un Hash (contenant :type et :value, et d’autres valeurs optionnelles)'
        end
      Field.new(form, "#{_prefix}#{field_ref}", field_value).set
    end
    self
  end


  # Pour remplir un formulaire QUIZ au hasard
  #
  # Pour le moment, ne fonctionne qu'avec des radio-bouton et
  # pour un QUIZ
  def au_hasard

    # Pour mettre les résultats qui pourront être récupérés par
    # .resultat
    @resultat = Hash.new

    js = <<-JS
var l = [];
$("form##{form_id} > div.question").each(function(){l.push($(this).attr('id'))});
return l;
    JS
    liste_questions = page.execute_script("#{js}")
    liste_questions.count > 0 || raise("Aucune question trouvée dans le formulaire form##{form_id}…")

    # puts "liste_questions : #{liste_questions.inspect}"
    liste_questions.each do |div_id|
      # div_id ressemble à 'question-xx'
      qid = div_id.split('-')[1]
      nombre_reponses = page.all("div##{div_id} > ul > li").count
      reponse_choisie = rand(nombre_reponses)
      @resultat.merge!( qid.to_i => reponse_choisie )
      li_id = "q-#{qid}-r-#{reponse_choisie}"
      page.execute_script("UI.scrollTo('div##{div_id} > ul > li##{li_id}', 200)")
      input_id = "q9r_rep#{qid}_#{reponse_choisie}"
      input_jid = "div##{div_id} > ul > li##{li_id} input##{input_id}"
      page.execute_script("$('#{input_jid}')[0].checked = true;")
    end

    return self
  end
  #/ au_hasard

  def et_le_soumet nom_bouton
    # On utilise deux façon de faire pour être sûr que ça fonctionne,
    # car ça ne fonctionne pas à tous les coups
    form.click_button(nom_bouton, match: :first)
    sleep 0.5
    within("form##{form_id}"){click_button(nom_bouton, match: :first)} rescue nil
    self
  end
  alias :et_clique :et_le_soumet

  # ---------------------------------------------------------------------
  #   Méthode de test
  # ---------------------------------------------------------------------
  def a_le_bouton_soumettre nom_bouton, options = nil
    options ||= Hash.new
    if form.has_button?(nom_bouton, options)
      success "Le formulaire a le bouton de soumission “#{nom_bouton}”."
    else
      raise "Le formulaire devrait avoir un bouton de soumission “#{nom_bouton}”."
    end
  end

  # ---------------------------------------------------------------------
  #   Class FormTest::Field
  #   ---------------------
  #   Un champ de formulaire
  #
  # ---------------------------------------------------------------------

  class Field

    include Capybara::DSL

    # Le FormTest du formulaire contenant le champ
    attr_reader :form
    attr_reader :id, :data
    def initialize form, field_id, field_data
      @form = form
      @id   = field_id
      @data = field_data
    end
    # def page; @page ||= form.page end
    def type
      @type ||= @data[:type] || :text
    end
    def value
      @value ||= @data[:value]
    end
    # La référence au champ
    def ref
      @ref ||= id || @data[:name]
    end
    # Méthode pour régler la valeur du champ en fonction de
    # son type
    def set
      case type
      when :text, :textarea then form.fill_in(ref, with: value)
      when :select    then form.select(value, from: ref)
      when :checkbox  then
        if data[:in]
          page.execute_script("UI.scrollTo('#{data[:in]}',100)")
        end
        goodref =
          if ref.start_with?('---') && ref.end_with?('---')
            data[:value] || data[:name]
          else
            ref
          end
        form.send(value ? :check : :uncheck, goodref)
      when :radio     then

        data.key?(:in) || raise('Pour les radio-boutons, il faut impérativement spécifier un container pour scroller jusqu’à lui (on ne peut pas cocher un élément invisible)')
        # Pour commencer, il faut scroller jusqu'à l'élément qui
        # contient le radio button
        page.execute_script("UI.scrollTo('#{data[:in]}',100)")
        sleep 0.8
        if data[:id]
          # Par l'identifiant, c'est le plus sûr
          rid = data[:id]
          jid = "input[type=\"radio\"]##{rid}"
          # container.find(jid).click
          # container.find('input[type="radio"]').click
          choose(rid)
        else
          # Il peut arriver que des noms soient identiques, dans ce cas-là,
          # on met une clé '--- X ---' et on met en valeur la référence du
          # bouton à cocher
          goodref =
            if ref.start_with?('---') && ref.end_with?('---')
              data[:value] || data[:name]
            else
              ref
            end
          container.choose(goodref)
        end
      else
        raise "Je ne sais pas encore traiter un champ de type #{type.inspect}."
      end
    end
    def container
      if within
        form.find(within)
      else
        form
      end
    end
    def within
      @within ||= data[:in]
    end
  end

end #/FormTest
