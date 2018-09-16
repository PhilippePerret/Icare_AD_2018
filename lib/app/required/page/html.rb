# encoding: UTF-8
class Page

  # Les styles CSS dynamiques à ajouter dans la page en fonction
  # de l'application
  def raw_css_for_app
    <<-CSS
relecture *, relecture{display:inline;color:#{user.admin? ? 'goldenrod' : 'inherit'} !important}
    CSS
  end
end
