# encoding: UTF-8
class SiteHtml
class Gel

  class << self

    # = main =
    #
    # Méthodes principales
    # @usage :
    #   Gel::gel 'nom-du-gel'[, <{options}>]
    #   Gel::degel 'nom-du-gel'[, <{options}>]
    def gel gel_name, options = nil
      new(gel_name).gel(options)
    end
    def degel gel_name, options = nil
      new(gel_name).degel(options)
    end

    # {SuperFile} Dossier contenant tous les gels
    def folder
      @folder_data ||= begin
        d = site.folder_data + 'gel'
        d.build unless d.exist?
        d
      end
    end

  end # << self

end #/Gel
end #/SiteHtml
