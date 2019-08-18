# encoding: UTF-8

class Atelier
class << self

  def nombres_documents
    nb_total = nombre_documents_total
    whereclause = "SUBSTRING(options,2,1) = '1' OR SUBSTRING(options,10,1) = '1'"
    nb_shared = dbtable_icdocuments.count(where: whereclause)
    ligne_stat('Nombre total de documents produits', nb_total) +
    ligne_stat('Nombre de documents partagés', nb_shared)
  end

  def moyenne_documents_par_mois
    nombre_mois = ((Time.now.year - 2008) * 12) + Time.now.month
    debug "nombre_mois : #{nombre_mois}"
    nb = nombre_documents_total / nombre_mois
    ligne_stat('Moyenne de documents par mois', nb)
  end

  def nombre_documents_total
    @nombre_documents_total ||= dbtable_icdocuments.count
  end

end#<< self
end#/ Atelier
