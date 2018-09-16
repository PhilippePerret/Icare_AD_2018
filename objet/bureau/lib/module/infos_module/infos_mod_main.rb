# encoding: UTF-8
class Bureau
class << self

  def icmod   ; @icmod  ||= user.icmodule   end
  def icetp   ; @icetp  ||= user.icetape    end
  def absmod  ; @absmod ||= icmod.abs_module  end
  def absetp  ; @absetp ||= icetp.abs_etape   end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper principales
  # ---------------------------------------------------------------------
  def _fs_module_courant
    (
      'Module courant'.in_div(class: 'titre') +
      ligne_titre_module        +
      ligne_start_module        +
      ligne_nombre_jours
    ).in_fieldset(id: 'infos_current_module')
  end

  # ---------------------------------------------------------------------
  #   Sous-méthodes d'helper
  # ---------------------------------------------------------------------

  def ligne_titre_module
    line_info 'module', absmod.name.upcase
  rescue Exception => e
    debug "ERREUR ligne_titre_module avec les informations suivantes :"
    debug "user.icmodule.id : #{user.icmodule.id rescue '- bug -'}"
    debug "user.icetape.id : #{user.icetape.id rescue '- bug -'}"
    debug e
    line_info 'module', '- indéfinissable -'
  end

  def ligne_start_module
    line_info 'depuis', icmod.started_at.as_human_date(true, true, nil, 'à')
  end

  def ligne_nombre_jours
    nbj = (Time.now.to_i - icmod.started_at)/1.day
    s = nbj > 1 ? 's' : ''
    line_info 'durée', "#{nbj} jour#{s}"
  end


    # ---------------------------------------------------------------------
    #
    def line_info lib, val, css = nil
      classe = ['infoline']
      css.nil? || classe << css
      (
        lib.in_span(class: 'libelle') +
        val.to_s.in_span(class: 'value')
      ).in_div(class: classe.join(' '))
    end

end #/<< self
end #/Bureau
