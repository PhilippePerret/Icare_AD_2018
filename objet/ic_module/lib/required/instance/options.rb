# encoding: UTF-8
class IcModule

  # Les options
  # BIT 1 (0)
  #   0: module non démarré,
  #   1: module en cours,
  #   2: module en pause,
  #   3: module achevé normalement,
  #   4: module abandonné
  def options ; @options  ||= get(:options)     end
  def bit1    ; @bit1     ||= options[0].to_i   end

  def non_started?  ; bit1 == 0 end
  def started?      ; bit1 == 1 end
  def en_pause?     ; bit1 == 2 end

  def type_suivi?
    @is_module_suivi ||= abs_module.type_suivi?
  end
end #/Icmodule
