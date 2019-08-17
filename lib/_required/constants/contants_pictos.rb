# encoding: UTF-8
# DOIGT       = "<span style='font-size:18pt;'>☛ </span>".freeze
# DOIGT_ROUGE = "<span style='color:red;font-size:18pt;'>☛ </span>".freeze

def picto_info
  @picto_info ||= image('pictos/picto_info.png', {alt:"Infos", style:'vertical-align:sub;'}).freeze
end


def picto_doigt color
  "<img src='./view/img/pictos/finger_#{color}.png' class='pdoigt' />".freeze
end
DOIGT         = picto_doigt('black')
DOIGT_ROUGE   = picto_doigt('red')
DOIGT_WHITE   = picto_doigt('white')
DOIGT_GOLD    = picto_doigt('gold')

ARROW         = "<span style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"
ARROW_RED     = "<span class='red' style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"
ARROW_BLUE    = "<span class='blue' style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"

FLASH = "<img src='./view/img/pictos/flash.png' class='pflash' />".freeze

def picto_punaise color
  "<img src='./view/img/pictos/punaise_#{color}.png' class='ppunaise' />".freeze
end
PUNAISE_ROUGE = picto_punaise('red')
PUNAISE_WHITE = picto_punaise('white')
PUNAISE_GOLD  = picto_punaise('gold')

# Retourne l'image de la mascotte du site
# +options+
#   Tous les attriuts qui seront transmis à in_image
#   +
#   :points   Si défini, le nombre de jours d'abonnements
#             gagnés si on clique sur la mascotte.
#   :raison   Si points est défini, on définit la raison qui
#             sera enregistrée avec l'ajout des jours.
#
def image_mascotte options = nil
  options ||= Hash.new
  points = options.delete(:points)
  if points
    app.session['nombre_points_gratuits']      = points
    app.session['session_id_points_gratuits']  = app.session.session_id
    app.session['raison_points_gratuits']      = options.delete(:raison)
    img = "./view/img/mascotte/mascotte-50pc.png".in_image
    img = img.in_a(href: "site/points_abonnement")
    img = (
      img +
      'cliquez-moi…'.in_div(style: 'font-size:9pt;text-align:center;color:#777')
    ).in_div(options)
  else
    img = "./view/img/mascotte/mascotte-50pc.png".in_image(options)
  end
  return img
end
