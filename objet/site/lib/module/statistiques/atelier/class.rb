# encoding: UTF-8
class Atelier
class << self

  def update_stats_file
    code =
      'Icariennes & Icariens'.in_h3            +
      nombres_icariens            +
      nombres_icariens_actifs     +
      'Modules & étapes'.in_h3    +
      nombre_modules_suivis       +
      nombre_etapes_accomplies    +
      'Documents'.in_h3           +
      nombres_documents           +
      moyenne_documents_par_mois  +
      'Durées de travail'.in_h3   +
      duree_moyenne_travail       +
      plus_longues_durees
    stats_file.write code.force_encoding('utf-8')
  end

  def ligne_stat libelle, value
    (
      libelle.in_span(class:'libelle') +
      value.to_s.in_span(class:'value')
    ).in_div(class: 'lstat')
  end

  def nombres_icariens
    nb = dbtable_users.count
    nb_femmes = dbtable_users.count(where: {sexe: 'F'})
    nb_hommes = dbtable_users.count(where: {sexe: 'H'})
    ligne_stat 'Nombre total', "#{nb} — #{nb_femmes} auteures / #{nb_hommes} auteurs"
  end

  def nombres_icariens_actifs
    nb = dbtable_users.count(where: 'SUBSTRING(options,17,1) = "2"')
    ligne_stat 'Nombre actuel (en cours de module)', nb
  end

  def nombre_modules_suivis
    nb = dbtable_icmodules.count
    ligne_stat 'Nombre de modules suivis', nb
  end
  def nombre_etapes_accomplies
    nb = dbtable_icetapes.count
    ligne_stat 'Nombre d’étapes accomplies', nb
  end

  def nombres_documents
    nb_total = dbtable_icdocuments.count
    whereclause = "SUBSTRING(options,2,1) = '1' OR SUBSTRING(options,10,1) = '1'"
    nb_shared = dbtable_icdocuments.count(where: whereclause)
    ligne_stat('Nombre total de documents produits', nb_total) +
    ligne_stat('Nombre de documents partagés', nb_shared)
  end

end#<< self
end#/ Atelier
