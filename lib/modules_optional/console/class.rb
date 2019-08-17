# encoding: UTF-8

require_folder "./lib/console/sub_methods"
require './lib/console/execution'
require './lib/console/help'

class SiteHtml
class Admin
class Console
  class << self
    def current
      @current ||= begin
        new().init # return self
      end
    end
  end
end #/Console
end #/Admin
end #/SiteHtml
