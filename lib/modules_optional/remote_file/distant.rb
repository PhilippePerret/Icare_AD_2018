# encoding: UTF-8
class RFile

  # ---------------------------------------------------------------------
  #   Instance du fichier distant
  # ---------------------------------------------------------------------
  class Distant

    # Instance RFile du fichier local
    attr_reader :rfile

    def initialize rfile
      @rfile = rfile
    end

    def download
      # Créer la hiérarchie de dossier en local si nécessaire
      `ssh #{rfile.serveur_ssh} "mkdir -p #{path_no_dot}"`
      `scp -p #{rfile.serveur_ssh}:#{path} #{local_path}`
      success = File.exist? local_path
      mess = "DOWNLOAD du fichier `#{path}` "
      mess << ( success ? "opéré avec succès." : "manqué…")
      mess = mess.in_span(class: (success ? nil : 'warning'))
      mess << "Contrôler/revenir".in_a(href:route_courante).in_p(class:'right')
      rfile.message = mess
    end

    # Permet de donner un autre nom au téléchargement local du
    # fichier distant. C'est utile lorsque l'on ne veut pas
    # remplacer le fichier local.
    # Noter que la méthode n'existe pas (encore ?) : on ne peut
    # pas donner un autre nom au fichier local uploadé, ce qui
    # n'aurait pas vraiment de sens
    def downloaded_file_name= new_name = nil
      @downloaded_file_name = new_name
    end
    # Idem que ci-dessus, mais en définissant le path exacte
    def downloaded_path= new_path = nil
      @downloaded_path = File.expand_path(new_path)
    end

    # Date de dernière modification
    def mtime
      @mtime ||= begin
        res = `ssh #{rfile.serveur_ssh} "ruby -e \\"STDOUT.write File.stat('#{path}').mtime.to_i\\""`
        res.to_i
      end
    end

    # Pour détruire le fichier distant
    def destroy
      mess = "DESTRUCTION du fichier distant `#{path}` "
      res = `ssh #{rfile.serveur_ssh} "ruby -e \\"File.unlink('#{path}');STDOUT.write File.exist?('#{path}').inspect\\""`
      @is_exist = nil
      mess << ((false == exist?) ? "opérée avec succès" : "manquée…")
      rfile.message = mess
    end

    def exist?
      @is_exist ||= begin
        "true" == `ssh #{rfile.serveur_ssh} "ruby -e \\"STDOUT.write File.exist?('#{path}').inspect\\""`
      end
    end

    # Path locale pour le fichier downloadé
    # C'est le path normal du fichier de référence, sauf si on
    # a défini `downloaded_file_name`
    # Noter qu'on la calcule chaque fois pour être sûr de définir
    # la bonne dans le cas où `downloaded_file_name` est modifié
    # après un premier download ou autre
    def local_path
      if @downloaded_file_name != nil
        File.join(File.dirname(rfile.path), @downloaded_file_name)
      elsif @downloaded_path != nil
        @downloaded_path
      else
        rfile.path
      end
    end

    # Pour le fichier distant ça correspond à la même chose, normalement
    def path_no_dot
      @path_no_dot ||= path
    end

    def path
      @path ||= "www/#{rfile.path_no_dot}"
    end

  end #/Distant

end #/RFile
