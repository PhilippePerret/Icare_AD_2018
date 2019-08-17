# encoding: UTF-8
=begin

  Méthode `la_page_a_...`

=end

=begin

  Usage

    TestTag.has_tag?(<tagname>[, <option>[, <texte>]])
    # Retourne true ou false en fonction de l'existence de la
    # balise.
    #
    # +options+ doit contenir les attributs de la balise.
=end

class TestTag
  include RSpec::Matchers
  include RSpecHtmlMatchers
  include Capybara::DSL

  class << self
    def has_tag? tag, options, text = nil
      new(tag).has_tag?(tag, options, text)
    end
  end

  def cpage ; @cpage ||= Capybara.current_session end

  def has_tag? tag, options, text = nil
    if text.nil?
      expect(cpage).to have_tag(tag, with: options)
    else
      expect(cpage).to have_tag(tag, with: options, text: text)
    end
    true
  rescue Exception => e
    false
  end

  attr_reader :jid
  def initialize jid
    @jid = jid
  end
  # def contient_la_balise tagname, args = nil
  #   args = LaPage.options_from_args(args)
  #   args.key?(:id)    && tagname << "##{args.delete(:id)}"
  #   args.key?(:class) && tagname << ".#{args.delete(:class)}"
  #   mess_success = args.delete(:success) || "La balise contient #{tagname}"
  #   mess_failure = args.delete(:failure) || "La balise devrait contenir #{tagname}"
  #   # args.merge!(visible: true)
  #   if page.find(jid).has_css?(tagname, args)
  #     success mess_success
  #   else
  #     raise mess_failure
  #   end
  # end
end

class LaPage

  include RSpec::Matchers
  include RSpecHtmlMatchers
  include Capybara::DSL

  attr_reader :options

  def initialize

  end
  def cpage ; @cpage ||= Capybara.current_session end

  # Retourne TRUE si la checkbox ou la radio définie par
  # +tagspec+ (qui peut contenir le container) est cochée ou non
  def is_checked? tagspec, options
    # puts "tagspec dans is_checked? : #{tagspec.inspect}"
    # puts "options dans is_checked? : #{options.inspect}"
    options.key?(:id)     && tagspec += "##{options[:id]}"
    options.key?(:type)   && tagspec += "[type=\"#{options[:type]}\"]"
    options.key?(:name)   && tagspec += "[name=\"#{options[:name]}\"]"
    options.key?(:value)  && tagspec += "[value=\"#{options[:value]}\"]"
    codejs = "return $('#{tagspec}')[0].checked;"
    return cpage.execute_script(codejs)
  end

  def contient_la_balise tagname, args = nil
    checked = (args||{}).delete(:checked)
    options_from_args(args)
    options_init = options.dup
    tag_id = options[:with][:id].freeze
    tagchecked = in_tag ? "#{in_tag} #{tagname}" : tagname.dup

    if checked === nil
      # Cas normal simple
      expect(cpage).to have_tag(tagchecked, options)
      success( @message_success || begin
          intag_message = in_tag ? "dans #{in_tag} " : ''
          "La page possède la balise #{tagname} #{intag_message}(arguments : #{options.inspect})"
        end
        )
    else
      # Si c'est un champs checkbox ou radio qui doit être
      # sélectionné
      is_checked = is_checked?(tagchecked, options[:with])
      if checked == is_checked
        success @message_success || "La page contient la balise #{tagchecked} #{checked ? 'cochée' : 'non cochée'}."
      else
        "La page devrait contenir la balise #{tagchecked} #{checked ? 'cochée' : 'non cochée'}."
      end

    end

  end
  def ne_contient_pas_la_balise tagname, args = nil
    checked = (args || {}).delete(:checked)
    options_from_args(args)
    options_init = options.dup
    final_tagname = tagname.dup
    options[:with].key?(:class)  && final_tagname << ".#{options[:with][:class]}"
    options[:with].key?(:id)     && final_tagname << "##{options[:with][:id]}"
    in_tag.nil? || final_tagname = "#{in_tag} #{tagname}".strip
    arguments = {visible: true}
    options.key?(:text) && arguments.merge!(text: options[:text])


    if cpage.has_no_css?(final_tagname, arguments)
      # Si la balise n'est pas trouvée, tout simplement
      success(@message_success || begin
          intag_message = in_tag ? "dans #{in_tag} " : ''
          "La page ne possède pas la balise '#{tagname}' #{intag_message} (arguments : #{options.inspect})"
        end
        )
    else
      # Si la balise est trouvée, et que checked est défini, il faut
      # faire un test pour voir si ça correspond vraiment
      if !(checked === nil)

        if checked == !is_checked?( final_tagname, options_init[:with] )
          success(@message_success || begin
              intag_message = in_tag ? "dans #{in_tag} " : ''
              "La page ne possède pas la balise '#{tagname}' #{intag_message} #{checked ? 'coché' : 'non coché'} (arguments : #{options.inspect})"
            end
            )
          return true
        end
      end
      raise "On ne devrait pas trouver la balise `#{final_tagname}' avec #{options.inspect}."
    end
  end

  def contient_le_texte str, args = nil
    options_from_args(args)
    if in_tag
      within(in_tag){expect(cpage).to have_content str}
    else
      expect(cpage).to have_content str
    end
    success(@message_success || begin
        intag_message = in_tag ? " dans #{in_tag}" : ''
        "La page affiche le texte “#{str}”#{intag_message}."
      end
      )
  end

  def ne_contient_pas_le_texte str, args = nil
    options_from_args(args)
    if in_tag
      within(in_tag){ expect(cpage).not_to have_content str }
    else
      expect(cpage).not_to have_content str
    end
    success(@message_success || begin
        intag_message = in_tag ? " dans #{in_tag} " : ''
        "La page ne possède pas le texte “#{str}”#{intag_message}."
      end
      )
  end

  def in_tag ; @in_tag end

  def options_from_args args
    args ||= Hash.new
    @message_success = args.delete(:success)
    @message_failure = args.delete(:failure)
    @options = self.class.options_from_args(args)
    @in_tag = @options.delete(:in)
  end

  # ---------------------------------------------------------------------
  #   Méthode de class
  # ---------------------------------------------------------------------

  # Note : mise ici, en méthode de classe, pour pouvoir être
  # appelée par les méthodes hors de la classe.
  #
  def self.options_from_args(args)
    options ||= Hash.new
    args != nil || (return options)

    args.key?(:dans) && args.merge!(in: args.delete(:dans))

    if args.key? :text
      t = args.delete :text
      t.instance_of?(Regexp) || t = /#{Regexp.escape t}/i
      options.merge!( text: t )
    end
    options.merge!(in: args.delete(:in)) if args.key?(:in)
    # Il faut toujours que l'élément soit visible
    # SAUF QUE… lorsque je mets le code ci-dessous, il me répond qu'on
    # ne trouve pas d'éléments avec la propriété visible="true"…
    # visi = args.key?(:visible) ? args.delete(:visible) : true
    # args.merge!(visible: visi)

    options.merge!(with: args)
    options
  end

end

def la_page_a_la_balise tagname, args = nil
  LaPage.new.contient_la_balise(tagname, args)
end
alias :la_page_contient_la_balise :la_page_a_la_balise
def la_page_napas_la_balise tagname, args = nil
  LaPage.new.ne_contient_pas_la_balise(tagname, args)
end
alias :la_page_ne_contient_pas_la_balise :la_page_napas_la_balise


def la_page_affiche texte, options = nil
  LaPage.new.contient_le_texte(texte, options)
end

def la_page_naffiche_pas texte, options = nil
  LaPage.new.ne_contient_pas_le_texte(texte, options)
end


def la_balise jid
  TestTag.new jid
end

def la_page_contient_le_bouton titre_bouton, options = nil
  options ||= Hash.new
  options.merge!(value: titre_bouton)
  in_tag = options.delete(:in) || options.delete(:dans)
  mess_success = options.delete(:success) || begin
    m = "La page contient le bouton%{type} “#{titre_bouton}”"
    in_tag.nil? || m << " dans #{in_tag}"
    m += '.'
  end

  if TestTag.has_tag?("#{in_tag} input[type=\"submit\"]".strip, options)
    success mess_success % {type: ' submit'}
  elsif TestTag.has_tag?("#{in_tag} input[type=\"button\"]".strip, options)
    success mess_success % {type: ''}
  else
    merr = "La page ne contient pas le bouton “#{titre_bouton}”"
    in_tag.nil? || merr += " dans #{in_tag}"
    merr += '.'
    raise merr
  end
end

def la_page_ne_contient_pas_le_bouton titre_bouton, options = nil
  options ||= Hash.new
  options.merge!(value: titre_bouton)
  options[:in] ||= options.delete(:dans)
  in_tag = options.delete(:in)
  mess_success = options.delete(:success) || begin
    mess = "La page ne contient pas le bouton “#{titre_bouton}”"
    in_tag.nil? || mess += " dans #{in_tag}"
    mess += '.'
    mess
  end
  napas =
    if cpage.has_css?('input[type="submit"]')
      searchtag = "#{in_tag} input[type=\"submit\"]".strip
      !cpage.has_css?(searchtag, with: options)
    elsif cpage.has_css?('input[type="button"]')
      searchtag = "#{in_tag} input[type=\"button\"]".strip
      !cpage.has_css?(searchtag, with: options)
    else
      true
    end
  if napas
    success mess_success
  else
    err_mess = "La page ne devrait pas contenir le bouton “Titre_bouton”"
    in_tag.nil? || err_mess += " dans #{in_tag}"
    err_mess += '.'
    raise err_mess
  end
end

def la_page_a_pour_titre titre, options = nil
  options ||= Hash.new
  options.merge!( text: titre )
  options.key?(:success) || options[:success] = "La page a pour titre “#{titre}”."
  la_page_a_la_balise 'h1', options
end
alias :la_page_a_le_titre :la_page_a_pour_titre

def la_page_napas_pour_titre titre, options = nil
  options ||= Hash.new
  options.merge!( text: titre )
  options.key?(:success) || options[:success] = "La page n'a pas pour titre “#{titre}”."
  la_page_napas_la_balise 'h1', options
end

def la_page_a_pour_soustitre stitre, options = nil
  options ||= Hash.new
  options.merge!( text: stitre )
  options.key?(:success) || options[:success] = "La page a pour sous-titre “#{stitre}”."
  la_page_a_la_balise 'h2', options
end
alias :la_page_a_le_soustitre :la_page_a_pour_soustitre

def la_page_napas_pour_soustitre stitre, options = nil
  options ||= Hash.new
  options.merge!( text: stitre )
  options.key?(:success) || options[:success] = "La page n'a pas pour sous-titre “#{stitre}”."
  la_page_napas_la_balise 'h2', options
end

def la_page_a_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient le formulaire ##{form_id}."
  options.merge!(id: form_id)
  la_page_contient_la_balise('form', options)
end
alias :la_page_contient_le_formulaire :la_page_a_le_formulaire

def la_page_napas_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas le formulaire ##{form_id}."
  options.merge!(id: form_id)
  la_page_ne_contient_pas_la_balise('form', options)
end
alias :la_page_ne_contient_pas_le_formulaire :la_page_napas_le_formulaire

def la_page_contient_la_section sect_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient la section ##{sect_id}."
  options.merge!(id: sect_id)
  la_page_contient_la_balise('section', options)
end
alias :la_page_a_la_section :la_page_contient_la_section

def la_page_ne_contient_pas_la_section sect_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas la section ##{sect_id}."
  options.merge!(id: sect_id)
  la_page_ne_contient_pas_la_balise('section', options)
end
alias :la_page_napas_la_section :la_page_ne_contient_pas_la_section


def la_page_contient_le_fieldset fs_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient le fieldset ##{fs_id}."
  options.merge!(id: fs_id)
  la_page_contient_la_balise('fieldset', options)
end
alias :la_page_a_le_fieldset :la_page_contient_le_fieldset

def la_page_ne_contient_pas_le_fieldset fs_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas le fieldset ##{fs_id}."
  options.merge!(id: fs_id)
  la_page_ne_contient_pas_la_balise('fieldset', options)
end
alias :la_page_napas_le_fieldset :la_page_ne_contient_pas_le_fieldset


def la_page_contient_le_fieldset o_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient le fieldset ##{o_id}."
  options.merge!(id: o_id)
  la_page_contient_la_balise('fieldset', options)
end
def la_page_ne_contient_pas_le_fieldset o_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas le fieldset ##{o_id}."
  options.merge!(id: o_id)
  la_page_ne_contient_pas_la_balise('fieldset', options)
end

def la_page_contient_le_div o_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient le div ##{o_id}."
  options.merge!(id: o_id)
  la_page_contient_la_balise('div', options)
end
def la_page_ne_contient_pas_le_div o_id, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas le div ##{o_id}."
  options.merge!(id: o_id)
  la_page_ne_contient_pas_la_balise('div', options)
end

def la_page_contient_le_lien titre, options = nil
  options ||= Hash.new
  options[:success] ||= "La page contient le lien “#{titre}”."
  options.merge!(text: titre)
  la_page_contient_la_balise('a', options)
end
alias :la_page_a_le_lien        :la_page_contient_le_lien
alias :la_page_affiche_le_lien  :la_page_contient_le_lien

def la_page_ne_contient_pas_le_lien titre, options = nil
  options ||= Hash.new
  options[:success] ||= "La page ne contient pas le lien “#{titre}”."
  options.merge!(text: titre)
  la_page_ne_contient_pas_la_balise('a', options)
end
alias :la_page_napas_le_lien :la_page_ne_contient_pas_le_lien

# +options+ peut définir :in, l'élément (formulaire) dans lequel
# se trouve l'objet
def la_page_contient_la_liste ul_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient la liste UL##{ul_id}."
  la_page_contient_la_balise 'ul', args.merge(id: ul_id)
end
alias :la_page_a_la_liste :la_page_contient_la_liste

def la_page_ne_contient_pas_la_liste ul_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas la liste UL##{ul_id}."
  la_page_napas_la_balise 'ul', args.merge(id: ul_id)
end
alias :la_page_napas_la_liste :la_page_ne_contient_pas_la_liste

def la_page_contient_le_menu select_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient le menu select##{select_id}."
  la_page_a_la_balise 'select', args.merge(id: select_id)
end
alias :la_page_a_le_menu :la_page_contient_le_menu

def la_page_ne_contient_pas_le_menu select_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas le menu select##{select_id}."
  la_page_napas_la_balise 'select', args.merge(id: select_id)
end
alias :la_page_napas_le_menu :la_page_ne_contient_pas_le_menu

def la_page_contient_la_section section_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient la section ##{section_id}."
  la_page_a_la_balise 'section', args.merge(id: section_id)
end
alias :la_page_a_la_section :la_page_contient_la_section

def la_page_ne_contient_pas_la_section section_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas la section ##{section_id}."
  la_page_napas_la_balise 'section', args.merge(id: section_id)
end
alias :la_page_napas_la_section :la_page_ne_contient_pas_la_section


def la_page_contient_le_message mess, options = nil
  options ||= Hash.new
  mess_succ = options.delete(:success) ||  "La page affiche le message flash “#{mess}”."
  in_tag = options.delete(:in)
  options.merge!(text: /#{Regexp.escape mess}/)
  options.merge!(class: 'notice', success: mess_succ, in: 'div#flash')
  la_page_contient_la_balise('div', options)
end
alias :la_page_a_le_message       :la_page_contient_le_message
alias :la_page_affiche_le_message :la_page_contient_le_message

def la_page_ne_contient_pas_le_message mess, args = nil
  args ||= Hash.new
  args.merge!(class: 'notice', in: 'div#flash')
  args[:success] || "La page n'affiche pas le message flash “#{mess}”."
  la_page_ne_contient_pas_la_balise('div', args)
end
alias :la_page_napas_le_message :la_page_ne_contient_pas_le_message
alias :la_page_n_affiche_pas_le_message   :la_page_ne_contient_pas_le_message

#
#
# Note : pour ce test, on attend quelques secondes si c'est en
# ajax.
# Note : le message d'erreur peut se trouver soit dans le flash soit
# dans un div de class warning.
def la_page_a_l_erreur err, options = nil
  options ||= Hash.new
  ajax = options[:ajax] == true
  options.merge!(text: /#{Regexp.escape err}/)
  hasflash, haserror = nil, nil
  # On attend 10 secondes qu'un message s'affiche
  tr = 0; while (tr += 1) < 10
    hasflash = cpage.has_css?('div#flash', options)
    haserror = cpage.has_css?('div.warning', options)
    ( hasflash || haserror )? break : (sleep 0.5)
  end
  if hasflash
    options.merge!(class: 'error', in: 'div#flash')
    options[:success] ||= "La page affiche le message d'erreur flash “#{err}”."
    la_page_a_la_balise 'div', options
  elsif haserror
    options.merge!(class: 'warning')
    options[:success] ||= "La page affiche le message warning “#{err}”."
    la_page_a_la_balise 'div', options
  else
    raise "La page ne contient pas le message d’erreur attendu “#{err}”…"
  end
end
alias :la_page_affiche_le_message_erreur :la_page_a_l_erreur
alias :la_page_contient_le_message_erreur :la_page_a_l_erreur


def la_page_ne_contient_pas_le_message_erreur err, options = nil
  options ||= Hash.new
  ajax = options[:ajax] == true
  options.merge!(text: /#{Regexp.escape err}/)
  hasflash, haserror = nil, nil
  # On attend 10 secondes qu'un message s'affiche
  tr = 0; while (tr += 1) < 10
    hasflash = cpage.has_css?('div#flash', options)
    haserror = cpage.has_css?('div.warning', options)
    ( hasflash || haserror )? break : (sleep 0.5)
  end
  if hasflash
    options.merge!(class: 'error', in: 'div#flash')
    options[:success] ||= "La page n'affiche pas le message d'erreur flash “#{err}”."
    la_page_napas_la_balise 'div', options
  elsif haserror
    options.merge!(class: 'warning')
    options[:success] ||= "La page n'affiche pas le message warning “#{err}”."
    la_page_napas_la_balise 'div', options
  else
    raise "La page ne devrait pas contenir le message d’erreur attendu “#{err}”…"
  end
end


def la_page_napas_derreur options = nil
  options ||= Hash.new
  mess_success = options[:success] || 'La page n’affiche pas de message d’erreur.'
  mess_failure = options[:failure] || 'La page ne devrait pas contenir d’erreur, elle contient les messages : %{erreurs}'
  if cpage.has_css?('div#flash div.error')
    # On récupère les messages d'erreur
    idiv = 0; erreurs = Array.new
    while cpage.has_css?("div#flash div.error:nth-child(#{idiv += 1})")
      o = cpage.find("div#flash div.error:nth-child(#{idiv})")
      erreurs << "“#{o.text}”"
    end
    raise ( mess_failure % {erreurs: erreurs.pretty_join} )
  else
    success mess_success
  end
end
alias :la_page_ne_contient_pas_derreur :la_page_napas_derreur

def la_page_a_l_erreur_fatale err, options = nil
  options ||= Hash.new
  ajax = options[:ajax] == true
  options.merge!(text: /#{Regexp.escape err}/)
  tr = 0; while (tr += 1) < 20
    cpage.has_css?('div#flash div.error', options) ? break : (sleep 0.5)
  end
  expect(cpage).to have_tag('div.fatal_error', options)
  success "La page affiche le message d'erreur fatale “#{err}”."
end
alias :la_page_affiche_le_message_fatal :la_page_a_l_erreur_fatale

def la_page_napas_derreur_fatale
  if cpage.has_css?('div.fatal_error')
    idiv = 0; erreurs = Array.new
    o = cpage.find('div.fatal_error')
    raise "La page ne devrait pas avoir rencontré d'erreur, elle a rencontré l'erreur fatale : #{o.text}"
  else
    success "La page n'affiche pas d'erreur fatale."
  end
end
alias :la_page_n_affiche_pas_de_message_fatal :la_page_napas_derreur_fatale

def la_page_a_le_menu select_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: select_id)
  expect(cpage).to have_tag("#{options[:in]} select".strip, options)
  success "La page possède le menu ##{select_id}."
end
def la_page_napas_le_menu select_id
  expect(cpage).not_to have_tag("select##{select_id}")
  success "La page ne possède pas le menu ##{select_id}."
end
