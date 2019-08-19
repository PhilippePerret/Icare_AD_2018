# encoding: UTF-8
class SiteHtml
class Watcher

  include MethodesMySQL

  def initialize wid, wdata = nil
    @id = wid
    @data_instanciation = wdata
    wdata.nil? || wdata.each{|k,v|instance_variable_set("@#{k}",v)}
  end

  # Méthode qui essaie de requérir l'objet du watcher (car on en a
  # toujours besoin, que ce soit pour l'affichage des notifications ou
  # l'envoi des mails)
  # + Le fichier required.rb s'il existe
  def require_objet_watcher_and_required_file
    site.require_objet objet
    required_file? && instance_eval(required_file.read)
  end

  def table; @table ||= self.class.table end
  def bind;  binding() end

end#/Watcher
end#/SiteHtml
