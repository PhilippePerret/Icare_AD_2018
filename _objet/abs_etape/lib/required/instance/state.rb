# encoding: UTF-8
class AbsModule
class AbsEtape

  # Retourne true si l'étape possède des documents QDD
  # Si +strict+ est true, on ne considère que les documents qui sont
  # partagés.
  def has_documents_qdd?(strict = true)
    # debug "-> has_documents_qdd?(strict = #{strict.inspect})"
    cond = Array.new
    cond << "abs_etape_id = #{id}"
    cond << "(SUBSTRING(options,6,1) = '1' OR SUBSTRING(options,14,1) = '1')"
    if strict
      cond << "(SUBSTRING(options,2,1) = '1' OR SUBSTRING(options,10,1) = '1')"
    end
    cond = cond.join(' AND ')
    # debug "condition : #{cond.inspect}"
    res = dbtable_icdocuments.count(where: cond) > 0
    # debug "À des documents ? #{res.inspect}"
    return res
  end

end #/AbsEtape
end #/AbsModule
