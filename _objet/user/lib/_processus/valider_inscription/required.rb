# encoding: UTF-8
=begin

  Toutes les méthodes requises pour la validation de l'inscription

=end
site.require_objet('abs_module')


# Pour ajouter une propriété qui indique si le module est choisi
class ::AbsModule
  attr_accessor :is_chosen
end

# (pour construire le formulaire admin)
def id_div_refus
  @id_div_refus ||= "div_motif_refus_watcher-#{self.id}"
end

# Retourne le formulaire pour l'administrateur
def admin_watcher
  ::AbsModule.list.each do |mod|
    mod.is_chosen = data_modules.include?(mod.id)
  end

  # Je voudrais pouvoir définir le formulaire de cette manière :
  site.require_module 'Form2Code'
  FormToCode.new((self.folder+'admin_notify.f2c.rb').to_s).build(self)
end

def menu_modules
  @menu_modules ||= begin
    (
      'Choisir le module…'.in_option(value: '') +
      ::AbsModule.list.collect do |mod|
        delimi = mod.is_chosen ? '***' : ''
        "#{delimi} #{mod.name} #{delimi}".in_option(value: mod.id)
      end.join +
      'Aucun (refus)'.in_option(value: '')
    ).in_select(id: "module_choisi-#{self.id}", name: 'module_choisi', onchange: "check_module_choisi(#{self.id}, this.value)")
  end
end

def lien_charger_documents
  @lien_charger_documents ||= 'Download présentation'.in_a(href: "admin/operation?opadmin=download_signup&sid=#{data}", class: 'fleft')
end


def data_modules
  @data_modules ||= begin
    if File.exist?(path_data_modules_raw)
      JSON.parse(File.read(path_data_modules_raw))
    else
      Marshal.load(path_data_modules.read)
    end
  end
end
def data_documents
  @data_documents ||= Marshal.load(path_data_documents.read)
end
def path_data_modules
  @path_data_modules ||= folder_signup + 'modules.msh'
end
# Ce path sert dans le cas où il faut modifier la liste
# des modules choisis par l'user en la forçant. Il suffit
# de faire un fichier 'modules.raw', dans son dossier
# d'inscription (dans tmp/signup) contenant la liste des
# ID de module : [<idmod1>, <idmod2>, ...]
def path_data_modules_raw
  @path_data_modules_raw ||= folder_signup + 'modules.raw'
end
def path_data_documents
  @path_data_documents ||= folder_signup + 'documents.msh'
end

# Le dossier contenant les données de l'inscription
def folder_signup
  @folder_signup ||= site.folder_tmp + "signup/#{data}"
end

# Pour construire le formulaire au besoin
admin_watcher
