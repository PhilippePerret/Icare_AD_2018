# encoding: UTF-8
class SiteHtml
class Updates
class Update

  class << self

    def human_type_list
      @human_type_list ||= begin
        SiteHtml::Updates::TYPES.keys.join(', ')
      end
    end
  end #<< self
  
end #/Update
end #/Updates
end #/SiteHtml
