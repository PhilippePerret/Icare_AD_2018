# encoding: UTF-8
=begin

  class Watchers pour l'user
  --------------------------
  Ce module peut être utilisé seul, sans toutes les librairies
  des watchers

=end
site.require_module 'watchers'

class Watchers

  # {User} possesseur des watchers
  attr_reader :owner

  # +owner+ {User} des watchers à traiter
  def initialize owner
    @owner = owner
  end

  def list
    @list ||= begin
      self.class.table.select(where: {user_id: owner.id}).collect do |hwatcher|
        Watcher.new(hwatcher[:id], hwatcher)
      end
    end
  end

  # Détruie tous les watchers du propriétaire
  def remove
    self.class.table.delete(where: {user_id: owner.id})
    @list = nil
  end

end#/Watchers
