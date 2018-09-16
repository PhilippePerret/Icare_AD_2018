# encoding: UTF-8
class AbsModule
class << self

  # Menu pour choisir un module d'apprentissage dans un menu select
  #
  def menu attrs = nil
    attrs ||= Hash.new
    attrs.merge!(
      id:'select_absmodule_id', name: 'absmodule[id]', class: 'absmodules', onchange: "AbsModule.set_action_choix_module(this.form)"
    )
    (
      [
        ['', 'Édition du module…']
      ] +
      table.select(order: 'id', colonnes: [:name]).collect do |hmod|
        [ hmod[:id], hmod[:name] ]
      end
    ).in_select(attrs).in_form(id: 'form_edit_module')
  end

end #<< self
end #AbsModule
