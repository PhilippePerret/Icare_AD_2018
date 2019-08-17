# encoding: UTF-8
=begin

  Les chainages méthode action.

  Par exemple :

    Phil clique le bouton 'OK', in: 'form#mon-formulaire'

  Ils sont reconnaissables au fait que les deux premiers correspondent à :

    Mot 1 : Quelqu'un, l'utilisateur courant
    Mot 2 : Une action, comme ici le clique sur un bouton

=end

# ---------------------------------------------------------------------
#   Actions
# ---------------------------------------------------------------------
def clique chaine
  chaine << 'clique'
end
# Soit employé :
#   sim.user choisit le menu '...', ...
# Soit :
#   sim.user choisit '...', ...
# C'est la présence du 2e argument qui détermine l'utilisation
def choisit chaine, args = nil
  if args == nil
    chaine << 'choisit'
  else
    chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, args)
    chaine << 'choisit_le_menu'
  end
end
alias :selectionne :choisit
def remplit chaine
  chaine << 'remplit'
end
def recoit chaine
  chaine << 'recoit'
end
def coche chaine
  chaine << 'coche'
end
def attache chaine
  chaine << 'attache'
end
def recharge chaine = nil, args = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, args)
  chaine << 'recharge'
end
def telecharge chaine
  chaine << 'telecharge'
end
def dezippe chaine
  chaine << 'dezippe'
end


# ---------------------------------------------------------------------
#   Derniers objets
# ---------------------------------------------------------------------
# p.e. "Phil clique le bouton ..."
def bouton chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'bouton'
end
def menu chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'menu'
end
# p.e. "Benoit remplit le formulaire avec ..."
def avec chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'avec'
end
# p.e. 'Phil remplit le champ '
def champ chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'champ'
end
# p.e. 'Phil recoit le mail ... '
def mail chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'mail'
end

def fichier chaine, options = nil
  chaine.instance_of?(ChaineMethod) || chaine = ChaineMethod.new(chaine, options)
  chaine << 'fichier'
end
alias :document :fichier
