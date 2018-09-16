# encoding: UTF-8

def absetape
  @absetape ||= instance_objet
end
def question
  @question ||= data.force_encoding('utf-8')
end
def reponse
  @reponse ||= param_minifaq[:reponse]
end

def pour_minifaq?
  destination == 'rep'
end
def pour_auteur?
  destination == 'ica'
end
def pour_suppression?
  destination == 'not'
end

def destination
  @destination ||= param_minifaq[:destination]
end

def param_minifaq
  @param_minifaq ||= param(:minifaq) || Hash.new
end
