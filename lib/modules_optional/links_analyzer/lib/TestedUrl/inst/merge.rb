# encoding: UTF-8
=begin

  Méthodes pour merger deux routes, lorsqu'elles sont identiques
  mais que la seconde possède une ancre dans l'url

=end
class TestedPage

  # = main =
  #
  # Méthode qui merge les données de la page +tpage+ (instance
  # {TestedPage}) dans la TestedPage courante
  def merge tpage
    @depths += tpage.depths
    @depths.sort # attention : pas d'uniq ici !
    # Le nombre d'appels, de libellés d'appels et de
    # provenance d'appel
    @call_count += tpage.call_count
    @call_texts += tpage.call_texts
    @call_texts = @call_texts.uniq
    @call_froms += tpage.call_froms
    @call_froms = @call_froms.uniq
    # Les erreurs rencontrées dans l'autre page se reportent
    # ici
    @errors += tpage.errors
    @is_valide = @errors.count == 0

    # Si la liste `invalides` de la classe class contenait
    # la route (route_init) alors il faut la remplacer par
    # la route sans anchor et la rendre unique
    if TestedPage.invalides.include?(tpage.route_init)

    end

  end

end #/TestedPage
