# encoding: UTF-8
=begin
  Méthodes pour les pauses
=end
class IcModule

  def liste_pauses
    JSON.parse(pauses.nil_if_empty || "[]").to_sym
  end

  # On instancie une pause pour le module d'apprentissage
  # Cela consiste à :
  #   * Ajouter un élément à `pauses`, qui est une liste de
  #     Hash qui contiennent {:start, :end} (timestamp secondes)
  #   * Mettre le premier bit des options à 2
  #
  def start_pause
    new_pauses = liste_pauses
    new_pause = {start: Time.now.to_i, end: nil}
    new_pauses << new_pause
    set(options: options.set_bit(1,2), pauses: new_pauses.to_json)
    owner.set_en_pause
  end

  # On stoppe un module qui doit être en pause.
  # Cela consiste à :
  #   * Renseigner la propriété `:end` du dernier élément
  #     de `pauses`
  #   * Mettre le premier bit des options du module à 1
  #
  def stop_pause
    new_pauses = liste_pauses
    last_pause = new_pauses.last
    if last_pause[:end] == nil
      last_pause[:end] = Time.now.to_i
      new_pauses[-1] = last_pause
      set(options: options.set_bit(1,1), pauses: new_pauses.to_json)
      owner.unset_en_pause
    else
      error "Ce module ne semble pas être en pause…"
    end
  end

end #/IcModule
