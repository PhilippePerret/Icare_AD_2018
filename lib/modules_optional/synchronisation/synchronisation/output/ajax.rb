#!/usr/bin/ruby
# encoding: UTF-8

=begin

  Script qui reçoit la requête ajax

  IL FAUT QU'IL SOIT EXÉCUTABLE

=end
require 'json'
require 'cgi'

def synchro
  @synchro ||= begin
    require '../../../../../_objet/site/data_synchro'
    Synchro.new
  end
end
def serveur_ssh
  @serveur_ssh ||= synchro.serveur_ssh
end

cgi = CGI.new('html4')
request = cgi["request"]
path    = cgi["path"]

class Ope
  class << self
    attr_reader :message, :success
    attr_accessor :path
    def upload
      @message = Array.new
      # @message << "-> upload"
      # @message << "serveur_ssh : #{serveur_ssh}"
      # @message << "real_path : #{real_path}"
      `ssh #{serveur_ssh} "mkdir -p #{File.dirname(remote_path)}"`
      `scp -p #{real_path} #{serveur_ssh}:#{remote_path}`
      @success = distant_file_exists?
      @message << "Upload du fichier #{path} "
      @message << (@success ? "opéré avec succès" : "manqué…")
      @message = @message.join('<br>')
    end
    def download
      folders_up_to path_no_dot
      `scp -p #{serveur_ssh}:#{remote_path} #{real_path}`
      @success = File.exist? real_path
      @message = "Download du fichier #{path} "
      @message << (@success ? "opéré avec succès" : "manqué…")
    end
    def destroy
      local = File.exist? real_path
      @message = "Destruction du fichier #{local ? 'local'  : 'distant'} "
      if local
        File.unlink real_path
        @success = false == File.exist?(real_path)
      else
        remote_destroy
        @success = false == distant_file_exists?
      end
      @message << (@success ? "opérée avec succès" : "manquée…")
    end

    ## Construit la hiérarchie locale jusqu'au dossier +path+
    def folders_up_to path
      current_relpath = "#{folder_app}" # le chemin courant testé
      File.dirname(path).split('/').each do |dossier|
        current_relpath = File.join(current_relpath, dossier)
        Dir.mkdir(current_relpath, 0755) unless File.exist? current_relpath
      end
    end
    def distant_file_exists?
      "true" == `ssh #{serveur_ssh} "ruby -e \\"STDOUT.write File.exist?('#{remote_path}').inspect\\""`
    end

    def remote_destroy
      `ssh #{serveur_ssh} "ruby -e \\"File.unlink('#{remote_path}');STDOUT.write File.exist?('#{remote_path}').inspect\\""`
    end

    def path_no_dot
      @path_no_dot ||= path[2..-1]
    end
    def remote_path
      @remote_path ||= "www/#{path_no_dot}"
    end

    def real_path
      File.join(folder_app, path_no_dot)
    end
    def folder_app
      @folder_app ||= begin
        @relative_folder = ""
        folder_name = "#{folder}"
        begin
          folder_name = File.dirname(folder_name)
          @relative_folder << "../"
        end while File.basename(folder_name) != synchro.app_name
        @relative_folder
      end
    end
    def folder
      @folder ||= File.expand_path('.')
    end
  end
end
Ope.path = path
Ope.send(request.to_sym)

data = {request: request, message: "#{Ope.message}", success: Ope.success}.to_json
# puts
STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
STDOUT.write data
