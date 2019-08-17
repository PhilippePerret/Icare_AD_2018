# encoding: UTF-8

module Capybara
  class Session

    def _try_ message, condition = nil
      error = false
      unless message.instance_of?(Hash)
        message = { message => condition }
      end
      message.each do |mess, cond|
        error ||= mess unless cond
      end
      !error or raise Capybara::ExpectationNotMet, error
    end

    def has_titre? name
      _try_ "Le titre de la page n'est pas “#{name}”.", self.has_css?('h1', text: name)
      # error = false
      # error ||= "Le titre de la page n'est pas “#{name}”." unless self.has_css?('h1', text: name)
      # !error or raise Capybara::ExpectationNotMet, error
    end

    def has_sous_titre? name
      _try_ "Le sous-titre de la page n'est pas “#{name}”.", self.has_css?('h2', text: name)
    end
    def has_formulaire? form_id
      _try_ "La page ne contient pas de formulaire d'identifiant #{form_id}", self.has_css?("form##{form_id}")
    end

    def has_submit? name, options = nil
      _try_ "Le bouton-submit “#{name}” est introuvable", self.has_css?("form input[type=\"submit\"][value=\"#{name}\"]")
    end
    def has_not_submit? name, options = nil
      _try_ "Le bouton-submit “#{name}” ne devrait pas exister", self.has_css?("form input[type=\"submit\"][value=\"#{name}\"]")
    end

    def page? key_page, options = nil
      self.send("#{key_page}_page?".to_sym)
    end
    def home_page? options = nil
      _try_(
        "le bouton aperçu de l'atelier est introuvable, ce n'est pas la page d'accueil" => self.has_css?('a#btn_overview'),
        "le fieldset de l'article courant est introuvable, ce n'est pas la page d'accueil" => self.has_css?('fieldset#article_courant')
      )
    end
    def bureau_page? options = nil
      ok = has_css?('h1', text: "Votre bureau")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver sur le bureau"
      true
    end
    def contact_page? options = nil
      error = false
      _try_(
        "Le titre n'est pas “Contact”"  => has_css?('h1', text: "Contact"),
        "Le formulaire de contact est introuvable" => has_css?('form#form_contact')
      )
    end
    def dashboard_page? options = nil
      ok = has_css?('h1', text: "Bureau administrateur")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver sur le bureau de l'administration"
      true
    end
    def preferences_page? options = nil
      ok = has_css?('h1', text: "Vos préférences")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver dans la section des préférences"
      true
    end
    alias :admin_page? :dashboard_page?
    def plan_page? options = nil
      ok = has_css?('h1', text: "Plan de l'atelier")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver sur le plan de l'atelier"
    end
    def historique_page? options = nil
      ok = has_css?('h1', text: "Historique de travail")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver sur un historique de travail"
    end
    # Pour vérifier qu'on est bien sur la page de la console d'administration
    # expect(page).to be_console_page
    def console_page? options = nil
      error = false
      error ||= ( false == has_css?('form#form_console') )
      error ||= ( false == has_css?('textarea#textarea_code_console') )
      !error or raise Capybara::ExpectationNotMet, "On devrait se trouver sur la page de la console d'administration"
    end
    def paiement_page? options = nil
      ok = has_css?('h1', text: "Paiement")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver sur la page de paiement"
      true
    end
    def narration_page? options = nil
      ok = has_css?('h1', text: "Narration")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver dans le livre Narration"
      true
    end
    def narration_collection_page? titre_page: nil, titre_livre: nil
      err_mess = "On devrait se trouver dans la collection Narration."
      ok = has_css?('h1', text: "Collection Narration")
      if ok && titre_page != nil
        ok = has_css?('h3', text: titre_page)
        err_mess << " Avec le titre de page “#{titre_page}”."
      end
      if ok && titre_livre != nil
        ok = has_css?('h1', text: titre_livre)
        err_mess << " Avec le titre de livre “#{titre_livre}”."
      end
      ok or raise Capybara::ExpectationNotMet, err_mess
    end
    alias :collection_narration_page? :narration_collection_page?
    def has_error? err_message = nil
      _try_(
        "La page ne contient aucun message d'erreur" => self.has_css?('div#flash div#errors div.error'),
        "La page contient des messages d'erreur mais pas le message “#{err_message}”" => self.has_css?('div#flash div#errors div.error', text: err_message)
      )
    end
    def has_not_error?
      _try_ "La page ne devrait pas contenir de messages d'erreur", self.has_css?('div#flash div#errors div.error')
    end
    def has_notice? mess = nil
      error = false
      no_message = !self.has_css?('div#flash')
      error ||= "La page ne contient aucun message" if no_message
      reg_mess =
        case mess
        when Regexp then mess
        else /#{Regexp::escape mess}/
        end
      unless self.has_css?('div#flash div.notice', text: reg_mess )
        messages = self.execute_script("return $('div#flash').html()")
        lemessage =
          if no_message
            "La page ne contient aucun message."
          else
            messages = messages.scan(/<div class="notice">(.*?)<\/div>/).collect{ |e| "“#{e.first}”" }
            "La page contient les messages #{messages.pretty_join} mais pas le message “#{mess}”"
          end
        error ||= lemessage
      end
      !error or raise Capybara::ExpectationNotMet, error
    end
    def aide_page? options = nil
      ok = has_css?('h1', text: "Aide de l'atelier")
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver dans la section Aide"
      true
    end
    def login_page? options = nil
      ok = has_css?('form#identify_form')
      ok or raise Capybara::ExpectationNotMet, "On devrait se trouver dans la page de login."
      true
    end
  end
end

RSpec::Matchers::define :have_link_aide do |params|
  match do |dom_element|
    @params = params
    # page.has_css?('a.lkaide', with:attrs_from_params(params))
    # page.html.has_tag?('a.lkaide', with:attrs_from_params(params))
    with = attrs_from_params
    expect(dom_element.html).to have_tag('a.lkaide', with: attrs_from_params)
    expect(dom_element).to have_css('a', text: titre_lien_aide)
  end

  def titre_lien_aide
    @titre_lien_aide ||= (@params[:titre] || "Aide")
  end

  def attrs_from_params
    @attrs_from_params ||= begin
      @params ||= {}
      attrs = {}
      rub   = @params.delete(:rubrique) || @params.delete(:mr)
      attrs = attrs.merge(mr: rub) unless rub.nil?
      srub  = @params.delete(:sous_rubrique) || @params.delete(:sr)
      attrs = attrs.merge(sr: srub) unless srub.nil?
      {href: qs_route('aide', attrs)}
    end
  end
  def balise_lien
    @balise_lien ||= begin
      titre_lien_aide.in_a(href: attrs_from_params[:href]).gsub(/</, '&lt;')
    end
  end
  def description
    "La page contient le lien d'aide #{balise_lien}"
  end
  def failure_message
    "La page devrait contenir le lien d'aide #{balise_lien}"
  end
  def failure_message_when_negated
    "La page ne devrait pas contenir le lien d'aide #{balise_lien}"
  end
end
