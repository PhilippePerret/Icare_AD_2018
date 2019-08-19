# encoding: UTF-8
class Page

  def widget_taches?
    user.admin? && !(@no_widget_taches == true || site.display_widget_taches == false)
  end

  def no_widget_taches
    @no_widget_taches = true
  end

end #/Page
