# encoding: UTF-8

require_folder "./lib/deep/console/sub_methods"
require './lib/deep/console/execution'
require './lib/deep/console/help'

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
