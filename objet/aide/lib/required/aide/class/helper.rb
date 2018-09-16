# encoding: UTF-8
class Aide

  extend MethodesMainObjet

  class << self

    def titre; @titre ||= "Aide du site".freeze end

    def data_onglets
      DATA_ONGLETS
    end

    def tdm
      (site.folder_objet+'aide/lib/data/tdm.rb').require
      DATA_TDM.collect do |route, ditem|
        if ditem[:titre]
          ditem[:hname].in_li(class:'titre')
        else
          route =
            case route
            when Fixnum then "aide/#{route}/show"
            else route
            end
          ditem[:hname].in_a(href:route).in_li(class:'page')
        end
      end.join('').in_ul(class:'tdm')
    end

  end #/ << self
end #/Aide
