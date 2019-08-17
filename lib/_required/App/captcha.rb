# encoding: UTF-8
=begin
  Méthode pour l'utilisation d'un captcha (dynamique, car si statique,
  il suffit de tester la valeur)

  @usage

    Définir dans la configuration (site/config.rb) :

        site.captcha_question = "<la question>"
        site.captcha_value = <la valeur quelconque attendue>

    Dans le formulaire, mettre un champ captcha (de nom indifférent)
    Ajouter aussi : <%= app.hidden_field_captcha_value %>

    Au moment du test du formulaire, utiliser :

        app.captcha_valid?(<valeur fournie par l'user>)

    … pour tester la bonne valeur.
=end
class App

  # Retourne tous les champs utiles pour l'utilisation d'un captcha,
  # avec la question définie par site.captcha_value et site.captcha_question
  # (qui peut être définie automatiquement)
  def fields_captcha
    hidden_field_captcha_value +
    (site.captcha_question + ''.in_input_text(name:'captcha', class: 'short')).in_div(class: 'div_captcha')
  end

  # Utiliser app.captcha_valid? pour vérifier la valeur fourni par
  # l'utilisateur.
  def hidden_field_captcha_value
    require 'digest/md5'
    v = Digest::MD5::hexdigest("#{app.session.session_id}#{site.captcha_value}")
    "<input type='hidden' name='cachcapvalue' id='cachcapvalue' value='#{v}' />"
  end

  # Méthode qui retourne TRUE si le captcha est valide
  #
  # @usage      app.captcha_valid?(valeur_fournie)
  #
  # Pour pouvoir fonctionner on doit placer dans le formulaire un
  # champ hidden contenant la valeur cachcapvalue. On peut obtenir le
  # code HTML de ce champ par : app.hidden_field_captcha_value
  #
  # Si aucune valeur n'est fournie, il faut que la valeur du captcha
  # se trouve dans param(:captcha)
  def captcha_valid? captcha = nil
    captcha ||= param(:captcha)
    require 'digest/md5'
    param(:cachcapvalue) == Digest::MD5::hexdigest("#{app.session.session_id}#{captcha}")
  end

end #/App
