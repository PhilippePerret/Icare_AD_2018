# encoding: UTF-8
class Frigo
class Discussion

  include MethodesMySQL
  
  attr_reader :id

  # +tid+ Identifiant du thread. Nil si c'est un nouveau thread
  def initialize tid = nil
    @id = tid
  end

end #/Discussion
end #/Frigo
