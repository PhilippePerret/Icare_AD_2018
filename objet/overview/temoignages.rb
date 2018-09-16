# encoding: UTF-8

class Atelier
class Overview
class Temoignages
  include MethodesMySQL

  class << self

    # Construit et retourne le code HTML du listing des témoignages
    def listing
      # debug "temoignages.count : #{temoignages.count}"
      temoignages.collect do |dtem|
        (
          formate_content(dtem[:content]).in_div(class: 'content') +
          dtem[:user_pseudo].capitalize.in_div(class: 'pseudo')
        ).in_li(class: 'temoignage')
      end.join.in_ul(id: 'temoignages')
    end

    def formate_content content
      return content if content.match(/<p/)
      content.gsub!(/\r/, '')
      '<p>' + content.split("\n\n").join("</p><p>") + '</p>'
    end

    def temoignages
      @temoignages ||= begin
        table.select(order: 'created_at DESC')
      end
    end

    def table ; @table ||= site.dbm_table(:cold, 'temoignages') end

  end #/<< self
end #/Temoignages
end #/Overview
end #/Atelier
