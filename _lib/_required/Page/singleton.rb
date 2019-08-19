# encoding: UTF-8
=begin
Principale
=end

class Page; end

# La page courante
# Il n'y a en a toujours qu'une seule
def page
  @page ||= Page.instance
end

# Raccourci pour les paramètres
def param keyorhash
  page.param keyorhash
end
