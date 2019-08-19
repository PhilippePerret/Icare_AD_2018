# encoding: UTF-8
module TestMethodsFileAndFolder

  attr_reader :path
  attr_reader :hname

  # +path+ Le path (relatif) jusqu'à l'élémnet
  # +hname+ Le nom humain
  def initialize path, hname
    @hname  = hname
    @path   = path
  end

  # Méthodes de tests communes aux fichiers et aux
  # dossiers
  def exists as_case = true, inverse = false
    f_exists = ONLINE ? exists_online : exists_offline
    resultat = f_exists == !inverse
    as_case || (return resultat)
    SiteHtml::TestSuite::Case.new(nil, {
      result:         f_exists,
      positif:        !inverse,
      on_success:     "#{real_hname} existe bien.",
      on_success_not: "#{real_hname} n'existe pas (OK)",
      on_failure:     "#{real_hname} devrait exister.",
      on_failure_not: "#{real_hname} ne devrait pas exister."
    }).evaluate
  end
  def not_exists
    exists(as_case = true, inverse = true)
  end
  def exists?
    exists(as_case = false)
  end
  def not_exists?
    exists(as_case = false, inverse = true)
  end


  def exists_online
    "true" == `ssh #{serveur_ssh_boa} "ruby -e \\"STDOUT.write File.exist?('/home/boite-a-outils/www/#{path}').inspect\\""`
  end
  def exists_offline
    File.exist?(path)
  end

  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  def serveur_ssh_boa
    @serveur_ssh ||= begin
      require './_objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end

end


class SiteHtml
class TestSuite

# ---------------------------------------------------------------------
#   TFile
#   -----
#   On utilise la méthode `file(path, name)` dans les test-méthodes pour
#   produire un TFile
#
# ---------------------------------------------------------------------
class TFile
  include TestMethodsFileAndFolder

  def real_hname
    @real_hname ||= (hname || "Le fichier `#{path}`")
  end
end #/TFile

# ---------------------------------------------------------------------
#   TFolder
#   -------
#   On utilise la méthode `folder(path, name)` dans les tests-méthodes
#   pour produire un TFolder
#
# ---------------------------------------------------------------------
class TFolder
  include TestMethodsFileAndFolder

  def real_hname
    @real_hname ||= (hname || "Le dossier `#{path}`")
  end
end #/TFolder

end #/TestSuite
end #/SiteHtml
