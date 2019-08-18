# encoding: UTF-8
class Vue
class << self

  # cf. N0004
  def normalize(folder, relpath)
    begin
      if folder.nil? || folder == ''
        return [folder, relpath] if File.exists?(relpath)
        folder = site.folder_objet
        return [folder, relpath] if File.exists?(folder+relpath)
        unless relpath.end_with?('.erb')
          return [folder, "#{relpath}.erb"] if File.exists?(folder+"#{relpath}.erb")
        end
        raise
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
