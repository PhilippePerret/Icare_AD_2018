# encoding: UTF-8

CONSOLE_LIB_FOLDER = File.join(app.lib_folder,'console')
require_folder "#{CONSOLE_LIB_FOLDER}/sub_methods"
require "#{CONSOLE_LIB_FOLDER}/execution"
require "#{CONSOLE_LIB_FOLDER}/help"

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
