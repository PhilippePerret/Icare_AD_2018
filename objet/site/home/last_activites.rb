# encoding: UTF-8
=begin

  Bloc de l'accueil présentant les dernière activités

=end
class Home
class << self

  # Bloc contenant les dernières activités
  # Soit on lit le listing fabriqué courant, soit on l'actualise
  def bloc_dernieres_activites
    htmlfile = site.file_last_actualites
    # last_actu = dbtable_actualites.select(order: 'created_at DESC', limit: 1).first
    last_actu =
      if dbtable_actualites.exist?
        dbtable_actualites.last_update.to_i
      else
        nil
      end
    dernieres_activites =
      if last_actu.nil?
        'Aucune activité pour le moment.'.in_span(class: 'message').in_li(class: 'actu italic').in_ul(id: 'last_actualites')
      elsif htmlfile.exist? && last_actu < htmlfile.mtime.to_i
        htmlfile.read
      else
        # Il faut actualiser le listing des actualités
        site.require_objet 'actualite'
        SiteHtml::Actualite.listing_accueil
      end
    (
      'Dernières activités'.in_div(class:'titre') +
      dernieres_activites
    ).in_div(id: 'div_last_actualites')
  end

end #/<< self
end #/Home
