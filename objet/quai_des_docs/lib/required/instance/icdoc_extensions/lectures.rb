# encoding: UTF-8
=begin

  Extension de la classe IcModule::IcEtape::IcDocument pour le
  quai des docs

=end
class IcModule
class IcEtape
class IcDocument

  # Ajoute une lecture pour le document courant, pour l'user courant
  def add_lecture
    dlec = {
      user_id:        user.id,
      icdocument_id:  self.id,
      created_at:     Time.now.to_i,
      updated_at:     Time.now.to_i
    }
    table_lecture.insert dlec
  end


  def table_lecture; @table_lectures ||= QuaiDesDocs.table_lectures end

end #/IcDocument
end #/IcEtape
end #/IcModule
