# encoding: UTF-8
class Signup
class << self

  # Bandeau, au-dessus de la page d'inscription, indiquant
  # où l'on en est.
  def bandeau_states
    {
      'identite'      => {hname: '1. Identité'},
      'modules'       => {hname: '2. Choix modules'},
      'documents'     => {hname: '3. Présentation'},
      'confirmation'  => {hname: '4. Confirmation'}
    }.collect do |idstate, dstate|
      div_class = ['badge mr-5'] # bootstrap
      selected = (state == idstate)
      selected && div_class << 'badge-primary'
      div =
        if state_done?(idstate)
          href = "#{site.current_route.route}?signup[state]=#{idstate}"
          selected || div_class << 'badge-success'
          dstate[:hname].in_a(href: href, style: 'color:white')
        else
          selected || div_class << 'badge-secondary'
          dstate[:hname]
        end
      div.in_div(class: div_class.join(' ') )
    end.join.in_div(class: 'container center-mobile')
  end

  # Chargement de la vue (dans le dossier signup/view/)
  def view relpath
    (folder_views + relpath).deserb(self)
  end

end #/ << self
end #/ Signup
