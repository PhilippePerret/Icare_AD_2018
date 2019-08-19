# encoding: UTF-8

class ::Array

  # Le `self' doit être une liste de cette forme :
  #     [
  #       <value>, <titre>[, <true si selected ou rien>],
  #       <value>, <titre>[, <true si selected ou rien>],
  #       etc.
  #     ]
  def in_select attrs = nil
    selected = attrs.delete(:selected)
    selected = selected.to_s
    self.collect do |doption|
      data_option = {value: doption[0]}
      if (doption[2] == true) || (selected != "" && selected == doption[0].to_s)
        data_option = data_option.merge( selected: true)
      end
      doption[1].to_s.in_option(data_option)
    end.join('').in_select attrs
  end

  def in_my_select attrs = nil
    # debug "attrs : #{attrs.inspect}"
    selected = attrs[:selected].nil_if_empty
    # Si aucun menu n'est sélectionné, il faut choisir
    # le premier (obligatoirement, sinon on ne verrait pas
    # le menu)
    self.collect do |doption|
      data_option = {value: doption[0]}
      # Il faut obligatoirement qu'il y ait un menu sélectionné
      # C'est soit celui défini soit le premier
      # Attention, la valeur "" est une bonne valeur.
      selected ||= begin
        attrs.merge!(selected: doption[0].to_s)
        attrs[:selected]
      end
      if (doption[2] == true) || selected == doption[0].to_s
        data_option = data_option.merge( selected: true)
      end
      doption[1].to_s.in_my_option(data_option)
    end.join('').in_my_select attrs
  end

  def nil_or_empty?
    self.count == 0
  end
end
