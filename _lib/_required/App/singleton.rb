# encoding: UTF-8
class App
  include Singleton
end

def app
  @app ||= App.instance
end
