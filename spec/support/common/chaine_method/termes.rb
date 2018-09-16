# encoding: UTF-8
=begin

  Définition des termes utilisables dans les méthodes-chaines de test.

=end

# ---------------------------------------------------------------------
#   Premier terme sujet
#   -------------------
#   C'est le terme qui lance l'évaluation de l'expression
# ---------------------------------------------------------------------
def Le chaine
  chaine << 'le'
  chaine.evaluate
end

def La chaine
  chaine << 'la'
  chaine.evaluate
end

# ---------------------------------------------------------------------
#   Intermédiaire ou premier
#   Les méthodes qui peuvent être en dernier ou à l'intérieur
#   d'une phrase
# ---------------------------------------------------------------------
def affiche chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'affiche'
end
# p.e. "La feuille affiche le message erreur ..."
def erreur chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'erreur'
end

# p.e. "La feuille ne contient pas derreur"
def derreur options = nil
  # chaine.instance_of?(ChaineMethod) ||
  chaine = ChaineMethod.new(nil, options)
  chaine << 'derreur'
end

# p.e. "La feuille affiche le message fatal ..."
def fatal chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'fatal'
end

# ---------------------------------------------------------------------
#   Mot d'intérieur de phrase
# ---------------------------------------------------------------------
def le chaine
  chaine << 'le'
end
def la chaine
  chaine << 'la'
end
def ne chaine
  chaine << 'ne'
end
def contient chaine
  chaine << 'contient'
end
def a chaine
  chaine << 'a'
end
def n chaine
  chaine << 'n'
end
def pas chaine
  chaine << 'pas'
end
def plus chaine
  chaine << 'pas'
end
def pour chaine
  chaine << 'pour'
end
def feuille chaine
  chaine << 'page'
end

# ---------------------------------------------------------------------
#   ÉLÉMENTS SÉMANTIQUES SANS EFFET
# ---------------------------------------------------------------------

def toujours chaine
  chaine
end

# P.e. La feuille contient encore le formulaire ...
def encore chaine
  chaine
end

# Soit 'Phil clique sur le bouton ...'
# Soit 'Benoit clique sur le lien ...' (un lien)
# On N'enregistre PAS ce mot
def sur chaine
  chaine
end


# ---------------------------------------------------------------------
#
#     ÉLÉMENTS DE BOUT DE CHAINE
#
# ---------------------------------------------------------------------

def formulaire chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'formulaire'
end
def liste chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'liste'
end
# # Sauf que ça parasite la méthode `lien` en mode unitaire ou simulation
# def lien chaine, options = nil
#   chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
#   chaine << 'lien'
# end
def link chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'lien'
end

def balise chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'balise'
end
def message chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'message'
end
def titre chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'titre'
end
def soustitre chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'soustitre'
end
def fieldset chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'fieldset'
end
def div chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'div'
end
def section chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'section'
end
def fieldset chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'fieldset'
end
def checkbox chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'checkbox'
end
