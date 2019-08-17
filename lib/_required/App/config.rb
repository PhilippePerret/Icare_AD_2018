# encoding: UTF-8
=begin
  Scories de l'ancien atelier ?
=end
class App

  def config
    @config ||= Configuration.new(self)
  end
  def configure
    yield config
  end

  def require_config
    require(config_file)
  end

  def config_file
    @path_config_file ||= File.join('./config/app.rb')
  end

class Configuration
  attr_reader :app

  # Les propriétés à configurer
  attr_accessor :local_full_url, :distant_full_url


  def initialize app
    @app = app
  end
end #/Configuration
end #/App
