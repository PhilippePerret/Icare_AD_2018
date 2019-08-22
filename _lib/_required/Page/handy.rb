# encoding: UTF-8

# La page courante
# Il n'y a en a toujours qu'une seule
def page
  @page ||= Page.instance
end

# Raccourci pour les paramètres
def param keyorhash
  page.param keyorhash
end

def enable_comments
  Page::Comments.set_comments_on
end
def unable_comments
  Page::Comments.set_comments_off
end

def mobile_separator
  Page.mobile_separator
end

def space
  '<div>&nbsp;&nbsp;&nbsp;</div>'
end
