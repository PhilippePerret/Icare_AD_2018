# encoding: UTF-8
#
# Méthodes pour gérer les étapes des
# modules absolus
class AbsModule

  # Retourne l'instance AbsModule::AbsEtape de l'étape du
  # module courant correspondant à l'id +etape_id+ (qui
  # peut ne pas exister)
  def etape_by_id etape_id
    site.require_objet 'abs_etape'
    AbsModule::AbsEtape.new(etape_id)
  end

  # Retourne l'instance AbsModule::AbsEtape de l'étape
  # du module courant de numéro +etape_num+
  # Retourne NIL si l'étape est inconnue
  def etape_by_numero etape_num
    site.require_objet 'abs_etape'
    hrequest = {
      where: "module_id = #{id} AND numero = #{etape_num}",
      columns: []
    }
    res = AbsModule::AbsEtape.table.select(hrequest).first
    if res.nil?
      nil
    else
      AbsModule::AbsEtape.new(res[:id])
    end
  end

end #/AbsModule
