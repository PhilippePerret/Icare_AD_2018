# encoding: UTF-8
class Vue
class << self

  # cf. N0004
  def normalize(folder, relpath)
    begin
      if folder.nil? || folder == ''
        if File.exists?(relpath) && relpath.end_with?('.erb')
          return [folder, relpath]
        end
        folder = site.folder_objet
        if File.exists?(folder+relpath) && relpath.end_with?('.erb')
          return [folder, relpath]
        end
        if relpath.end_with?('.erb')
          raise "Impossible de trouver le fichier #{folder+relpath}"
        else
          return [folder, "#{relpath}.erb"] if (folder+"#{relpath}.erb").exists?
          affixe = relpath.split(File::SEPARATOR).last
          relpath = "#{relpath}/#{affixe}.erb"
          return [folder, relpath] if (folder+relpath).exists?
          raise "Le fichier n'existe pas : #{folder+relpath}"
        end
      end
      if relpath.end_with?('.erb')
        if (folder+relpath).exists?
          return [folder, relpath]
        else
          checkpath = relpath[0..-5]
          (folder+checkpath).exists? || raise
          folder = folder + checkpath
        end
      else # relpath sans '.erb' terminal
        # Sans '.erb' il peut s'agir soit d'un dossier, soit d'un fichier
        # dont le .erb a été omis cf. N0004
        if (folder+relpath).exists?
          folder = folder + relpath
        end
        relpath += ".erb"
      end
      (folder+relpath).exists? || raise
      return [folder, relpath]
    rescue Exception => e
      debug e
      raise("Le fichier '#{folder}/#{relpath}' est introuvable")
    end
  end
end #/<<self
end #/Vue
