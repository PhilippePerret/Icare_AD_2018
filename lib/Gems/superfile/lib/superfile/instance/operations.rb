# encoding: UTF-8
class SuperFile
  
  
  # Ajoute un chemin à la path courante et retourne une nouvelle
  # instance SuperFile
  def + pathrel
    raise "Impossible d'ajouter un path à un fichier" if file?
    raise ArgumentError, "L'argument de la méthode SuperFile#+ ne peut être NIL" if pathrel.nil?
    pathrel = ( File.join pathrel ) if pathrel.class == Array
    ::SuperFile::new File.join(path, pathrel.to_s)
  end

  # Retire du path la valeur de {String|SuperFile} pathmoins
  def - pathmoins
    psup      = pathmoins.to_s.dup
    # Si c'est à la fin
    new_path = self.expanded_path.sub(/\/?#{Regexp::escape psup}$/, '')
    unless new_path != self.expanded_path
      # Essayer de retirer au début
      psup_abs = File.expand_path(psup)
      new_path = self.expanded_path.sub(/^#{Regexp::escape psup_abs}\/?/, '')
    end
    if new_path != self.expanded_path
      new_path = new_path.sub(/^#{relative_folder}/, '.')
      SuperFile::new new_path
    else
      nil
    end
  end
  
end