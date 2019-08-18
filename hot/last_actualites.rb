# encoding: UTF-8
class SiteHtml

  # Dernières actualités générales qui apparaissent sur la page
  # d'accueil.
  # Cette méthode est utilisée par :
  #   ./_objet/site/lib/module/home_page/actualites.rb
  #
  def dernieres_actualites_generales
    drequest = {
      colonnes: [:message, :created_at],
      where: 'CAST(SUBSTRING(options,1,1) AS UNSIGNED) > 6',
      limit: 3,
      order: 'created_at'
    }
    liste_actus = []
    site.dbm_table(:cold, 'updates').select(drequest).each do |h|
      liste_actus << [h[:message], h[:created_at]]
    end
    # debug "liste_actus = #{liste_actus.inspect}"
    liste_actus
  rescue Exception => e
    debug e
    []
  end

end #/SiteHtml
