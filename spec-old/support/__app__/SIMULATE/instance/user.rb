# encoding: UTF-8
class Simulate

  attr_reader :user_id

  # Simulate#user est en même temps une propriété qui est une instance
  # {User} (quand il n'y a pas d'argument) ou une instance Someone qui
  # permet d'écrire les tests comme :
  #   sim = Simulate.new
  #   ....
  #   sim.user clique le bouton 'OK'
  #
  def user chaine = nil
    if chaine != nil
      Someone.new({user_id: user_id, pseudo: @user.pseudo}, chaine).evaluate
    else
      @user ||= User.new(user_id)
    end
  end

  # Il faut pouvoir rafraîchir la donnée user suite à des modifications importante,
  # comme avant et après le test, lorsque c'est l'user qui s'est connecté qui a
  # été modifié.
  def user= newu
    @user = newu
  end

end
