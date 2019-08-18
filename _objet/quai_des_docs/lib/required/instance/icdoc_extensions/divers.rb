# encoding: UTF-8
=begin

  Extension de la classe IcModule::IcEtape::IcDocument pour le
  quai des docs

=end
class IcModule
class IcEtape
class IcDocument

  # Checksum de l'ic-document
  # -------------------------
  # Calculé en fonction de la présence ou non du document original ou
  # du document commentaire, il permet d'être sûr que l'user ne cherche
  # pas à télécharger d'autres documents que le document pour lequel il
  # a une autorisation.
  def checksum
    require 'digest/md5'
    somme = 0
    somme += File.stat(qdd_path.to_s).size            if exist?(:original)
    somme += File.stat(qdd_path(:comments).to_s).size if exist?(:comments)
    Digest::MD5::hexdigest(somme.to_s)
  end

  def exist?(ty = :original)
    inscription? && (return false)
    qdd_path(ty).exist?
  end
  def qdd_path ty = :original ; qdd_folder_pdfs + qdd_name(ty)      end
  def qdd_name ty = :original ; "#{qdd_prefixe_filename}_#{ty}.pdf" end

  # Calcul du préfixe d'un document QDD dans le dossier qdfs/
  # Il aura l'allure : "Shortnamemodule_etape_<num étape>_Auteur_<doc id>"
  def qdd_prefixe_filename
    @qdd_prefixe_filename ||= begin
      self.icmodule.abs_module.module_id.camelize +
      "_etape_#{icetape.numero}_"   +
      (owner.pseudo.as_normalized_id rescue 'Pseudo_introuvable') +
      "_#{self.id}"
    end
  end

  # ---------------------------------------------------------------------
  #   Dossiers
  # ---------------------------------------------------------------------

  def qdd_folder_pdfs
    @qdd_folder_pdfs  ||= begin
      d = qdd_folder + "pdfs/#{icmodule.abs_module.id}"
      d.exist? || d.build
      d
    end
  end
  def qdd_folder
    @qdd_folder ||= SuperFile.new(File.expand_path('./data/qdd'))
  end


end #/IcDocument
end #/IcEtape
end #/IcModule
