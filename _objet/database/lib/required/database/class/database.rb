# encoding: UTF-8
class Database
class << self

  include MethodesMainObjet

  def titre ; @titre ||= 'Base de données' end
  def data_onglets
    {}
  end
end #/<< self
end #/Database
