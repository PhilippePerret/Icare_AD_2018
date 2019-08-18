# encoding: UTF-8
class SiteHtml
class Watcher

  extend MethodesMainObjet

  class << self
    def table
      @table ||= site.dbm_table(:hot, 'watchers')
    end

  end #/<< self
end#/Watcher
end#/SiteHtml
