# encoding: UTF-8
class Aide
class << self

  def folder_textes
    @folder_textes ||= folder_lib+'data/texte'
  end
end #/<< self
end #/Aide
