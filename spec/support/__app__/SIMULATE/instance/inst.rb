# encoding: UTF-8
class Simulate

  # L'ID de l'user qui a pu être traité par une des méthodes et
  # l'instance. Pour user_id et user cf. le fichier user.rb
  # attr_reader :user_id, :user

  # L'ID du watcher qui a pu être traité par une des méthodes
  attr_reader :watcher_id

  # L'ensemble des watchers qui ont été traités/créés dans une
  # des méthodes
  # Chaque élément est un {Hash} contenant les données enregistrées
  # dans la table des watchers
  attr_reader :watchers

  # Instanciation de la simulation
  def initialize
    @watchers = Array.new
    @user_id  = nil
    @user     = nil
    self.class.current_simulation = self
  end


end
