# encoding: UTF-8
class Fixnum

  def as_duree_jours
    n = self / 1.days
    n_annees  = n / 365
    reste     = n % 365
    n_mois    = reste / 30
    n_jours   = reste % 30
    m = Array.new
    n_annees > 0 && begin
      s = n_annees > 1 ? 's' : ''
      m << "#{n_annees} an#{s}"
    end
    n_mois > 0  && m << "#{n_mois} mois"
    n_jours > 0 && begin
      s = n_jours > 1 ? 's' : ''
      m << "#{n_jours} jour#{s}"
    end
    m.pretty_join
  end
end#/Fixnum
class Atelier
class << self

  # Retourne les statistiques des plus longues
  # durées de travail
  def plus_longues_durees
    classed = all_durees_travail.sort_by { |h| h[:duree] }
    plus_courte = classed.first
    plus_longue = classed.last
    site.require_objet 'ic_module'
    icmodule = IcModule.new(plus_longue[:id])
    u = User.new(plus_longue[:user_id])
    duree = plus_longue[:duree].as_duree_jours
    mod = "module #{icmodule.abs_module.name}".in_span(class: 'small')
    ligne_stat 'Plus longue durée réelle de travail', "#{duree} (<strong>#{u.pseudo.capitalize}</strong>, #{mod})"
  end



  # Retourne la durée moyenne de travail
  def duree_moyenne_travail
    somme = 0
    all_durees_travail.each do |hmod|
      somme += hmod[:duree]
    end
    moy = somme / all_durees_travail.count
    ligne_stat 'Durée moyenne de travail', moy.as_duree_jours
  end

  # Retourne la liste de toutes les durées de travail à l'atelier
  def all_durees_travail
    @all_durees_travail ||= begin
      req = {colonnes:[:started_at, :ended_at, :user_id]}
      dbtable_icmodules.select(req).collect do |hmod|
        hmod[:ended_at] != nil || next
        duree = hmod[:ended_at] - hmod[:started_at]
        duree > 0 || next
        hmod.merge!(duree: duree)
      end.compact
    end
  end

end #/<< self
end #/ Atelier
