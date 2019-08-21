# encoding: UTF-8
=begin
Extension de la class User pour les méthodes d'instance qui
gèrent les options.

Rappel :
Les "bits" 0 à 15 sont réservés à RestSite
Les bits 16 à 31 sont réservés à l'application propre
=end
class User


  # Retourne un Array à deux éléments dont le premier est
  # l'index de l'option de clé +key_option+ (par exemple :admin, :grade)
  # et le second est le nom de la variable d'instance qui conserve
  # cette option. Par exemple '@grade' pour le grade de l'utilisateur.
  # Si +key_option+ est l'index lui-même (Integer) il est retourné
  # accompagné de la valeur nil pour le nom de variable.
  # Note : Cette méthode est utilisée par les méthodes set_option
  # et get_option.
  def option_index_and_inst_name key_option
    case key_option
    when Symbol
      case key_option
      when :admin         then [0, nil]
      when :grade         then [1, '@grade']
      when :confirm_mail  then [2, nil]
      when :destroyed     then [3, nil]
      when :contact       then [4, nil]
        # :contact peut avoir différentes valeur en fonction de
        # l'application, mais il permet de définir comment l'user
        # veut être contacté par mail (quotidiennement, hebdomadairement,
        # etc.)
        # Pour icare, cf. OPTION 5 ci-dessous
      else
        # Peut-être défini en propre pour l'application courante dans
        # le fichier `./_objet/site/config.rb`
        # Cf. RefBook > User > Options.md
        site.user_options[key_option] unless site.user_options.nil?
      end
    when Integer
      [key_option, nil]
    end
  end

  # Index d'options : 0
  # Bit administrateur
  # 0:Simple user - 1:Administrateur - 2:Super - 4:Grand Manitou
  def admin?    ; get_option(:admin) & 1 > 0  end
  def super?    ; get_option(:admin) & 2 > 0  end
  def manitou?  ; get_option(:admin) & 4 > 0  end
  def phil?     ; manitou? && id == 1         end
  def set_admin bit_admin
    raise_unless_admin # seul un administrateur peut faire ça
    set_option(:admin, get_option(:admin)|bit_admin)
  end

  # Index d'option : 2
  # ------------------
  # Méthode utilisée par un ticket pour confirmer le mail
  # de l'user.
  # Note : on ne loggue pas l'user, pour qu'il ne repasse pas
  # par l'accueil avec le ticket dans l'URL.
  def confirm_mail
    set(options: (options||'').set_bit(2,1))
    flash "Merci à vous #{pseudo}, votre mail et votre inscription sont confirmés.<br />Vous pouvez vous identifier."
  end
  # Retourne true si le mail est bien confirmé
  def mail_confirmed? ; (options||'')[2].to_i == 1 end

  # OPTION 4 (indice 3)
  def bit_destroyed
    get_option(:destroyed)
  end

  # OPTION 5 (index 4)
  #   0   Veut recevoir le mail quotidien (défaut)
  #   1   Veut recevoir le mail seulement 1 fois par semaine
  #   9   Ne veut recevoir aucun mail
  def bit_mail_actu
    get_option(:contact)
  end

end #/User
