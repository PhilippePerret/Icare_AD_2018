# encoding: UTF-8
class AbsModules
class AbsEtapes
class AbsTravauxTypes

  REG_TRAVAIL_TYPE = /<%= travail_type '([a-z_]+)', '([a-z_]+)' %>/
  #<%= travail_type 'modules', 'debriefing_fin_module' %>

  # L'étape absolue propriétaire de ces travaux type
  attr_reader :abs_etape


  def initialize abs_etape
    @abs_etape = abs_etape
  end

  # La liste de tous les travaux types, comme instances de
  # {AbsModule::AbsEtape::AbsTravailType}
  def list
    @list ||= begin
      site.require_objet 'abs_travail_type'
      abs_etape.travail.scan(REG_TRAVAIL_TYPE).to_a.collect do |rubrique, shortn|
        hwt = dbtable_travaux_types.get(where: {rubrique: rubrique, short_name: shortn})
        if hwt
          AbsModule::AbsEtape::AbsTravailType.new hwt[:id]
        else
          send_error_to_admin(
            exception: (
              "Impossible de trouver le travail-type défini par :\n" +
              "Rubrique   : #{rubrique}\n" +
              "Short_name : #{shortn}" +
              "Défini pour l'étape absolue d'ID : #{abs_etape.id}"
              ).in_pre
          )
          nil
        end
      end.compact
    end
  end

  # Retourne la liste de tous les objectifs de tous les travaux-types
  # de l'étape absolue propriétaire. C'est une simple liste de string
  # des titres.
  def objectifs
    list.collect do |wtype|
      wtype.objectif.nil_if_empty
    end.compact
  end

  # Retourne la liste de tous les liens des travaux-types
  def liens
    arr_links = Array.new
    list.each do |wtype|
      wtype.liens.nil_if_empty.nil? && next
      arr_links += wtype.liens.split("\n").reject{|l| l.nil_if_empty}
    end
    return arr_links
  end

end #/AbsTravauxTypes
end #/AbsEtapes
end #/AbsModules
