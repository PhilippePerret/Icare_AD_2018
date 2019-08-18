# encoding: UTF-8
class Frigo
class Discussion
class Message

  include MethodesMySQL

  attr_reader :id

  # +mid+ Identifiant du message
  def initialize mid = nil
    @id = mid
  end

end #/Message
end #/Discussion
end #/Frigo
