# encoding: UTF-8
=begin

  Toutes les méthodes qui définissent le partage de la discussion.

=end
class Frigo
class Discussion

  SHARED_HUMAN_VALUES = {
    0 => {
      short: 'privée',
      owner: "privée : seuls votre interlocuteur et vous pouvez la lire.",
      inter: "privée : seuls l’icarien de ce bureau et vous pouvez la lire."
    },
    1 => {
      short: 'semi-publique',
      owner: 'semi-publique : tous les icariens peuvent la lire.',
      inter: 'semi-publique : tous les icariens peuvent la lire.'
    },
    2 => {
      short: 'publique',
      owner: 'publique : tout visiteur, même non icarien, peut la lire.',
      inter: 'publique : tout visiteur, même non icarien, peut la lire.'
    }
  }

  def set_partage
    frigo.owner? || begin
      raise 'Seriez-vous en train d’essayer de forcer une discussion qui ne vous appartient pas ?…'
    end
    set(options: options.set_bit(0, param(:discussion_partage).to_i))

    flash "Le partage de cette discussion a été mise à #{shared_hvalue}"
  end

  def shared?
    options[0].to_i > 0
  end

  def shared_world?
    options[0].to_i > 1
  end

  def shared_hvalue
    keyh = options[0].to_i
    keysoush = frigo.owner? ? :owner : :inter
    SHARED_HUMAN_VALUES[keyh][keysoush]
  end

  def shared_short_hmark
    keyh = options[0].to_i
    SHARED_HUMAN_VALUES[keyh][:short]
  end

end #/Discussion
end #/Frigo
