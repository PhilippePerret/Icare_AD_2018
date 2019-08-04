class Admin
class Checker


class << self

  require_relative('_module_messages')
  include MessagesMethods
  include HandyCheckerMethods

  # Table des valeurs à corriger
  # {
  #   db_suffix => table => id => {prop:value, prop:value}
  # }
  attr_reader   :data_correct

  # Pour les messages
  attr_accessor :msg
  attr_accessor :solution_keys

  # Méthode principale appelée quand on arrive sur la page
  # Si un icarien est déjà choisi, on lance le check ou la réparation
  # Si aucun icarien n'est choisi, on indique d'en choisir un dans le menu
  def operate
    @msg = []
    if param(:fname_corrections) && param(:corrections_confirmed)
      # Quand on a fait un premier check et qu'on procède aux corrections
      execute_corrections
    elsif param(:fname_corrections)
      confirm_corrections
    else
      if icarien_id
        init_check
        check_icarien
        save_corrections_todo
        @main_bouton_name = "Confirmer les corrections choisies"
      else
        @msg << "Choisir l'icarien à checker".in_div
      end
    end
    return @msg.join('')
  end

  def init_check
    @data_correct = {}
    @new_options = icarien.options
    @solution_keys = {}
  end

  # Méthode qui sauve les corrections à faire (@data_correct) pour les
  # exécuter si l'administration le réclame
  def save_corrections_todo
    corrections = @data_correct.to_json
    File.open(fpath_corrections,'wb'){|f| f.write corrections}
  end

  # Retourne le nom du fichier de corrections
  def fname_corrections
    @fname_corrections ||= param(:fname_corrections) || "check-user-#{now}.json"
  end
  def fpath_corrections
    @fpath_corrections ||= File.join(site.folder_tmp,fname_corrections)
  end


  def main_bouton_name
    @main_bouton_name
  end

  # Méthode pour ajouter une donnée à corriger
  # @param {String}   solution_id
  #                   L'id de la solution, pour savoir si la case est cochée et
  #                   qu'il faut l'appliquer.
  # @param {String}   solution_msg
  #                   Le message de la solution proposée (sera affiché avec une
  #                   checkbox pour l'appliquer)
  # @param {String}   db_suffix
  #                   Suffixe de la base (par exemple 'users' ou 'modules')
  #                   C'est ce qui sera ajouté à 'icare_' pour trouver la base
  # @param {String}   tbl_name  Nom de la table dans la base
  # @param {Integer}  id        Identifiant de l'enregistrement à modifier
  #                             Si cet argument est nil, c'est une insertion de
  #                             donnée avec un hash qui doit être défini dans
  #                             column ci-dessous
  # @param {String}   column    Le nom de la colonne à changer
  #                             OU  La table des donnéeds de l'élément à insérer
  #                                 si id = nil
  #                             ou  "DELETE" pour détruire la donnée d'identifiant id
  # @param {String}   value     La nouvelle valeur à mettre
  #                             OU  nil quand insertion ou suppression
  def correct(solution_id, solution_msg, db_suffix, tbl_name, id, column, value = nil)
    add_solution(solution_id, solution_msg)
    @data_correct[db_suffix] || @data_correct.merge!(db_suffix => {})
    @data_correct[db_suffix][tbl_name] || @data_correct[db_suffix].merge!(tbl_name => {})
    unless id === nil
      if column != 'DELETE'
        @data_correct[db_suffix][tbl_name][id] || @data_correct[db_suffix][tbl_name].merge!(id => {})
        @data_correct[db_suffix][tbl_name][id].merge!(column => {value:value, solution_id:solution_id})
      else
        @data_correct[db_suffix][tbl_name][:delete] || @data_correct[db_suffix][tbl_name].merge!(delete: [])
        @data_correct[db_suffix][tbl_name][:delete] << {value:id, solution_id:solution_id}
      end
    else
      # <= id est nil
      # => Insertion d'une donnée
      @data_correct[db_suffix][tbl_name][:insert] || @data_correct[db_suffix][tbl_name].merge!(insert: [])
      @data_correct[db_suffix][tbl_name][:insert] << column.merge(solution_id:solution_id)
    end

    debug("@data_correct = #{@data_correct.pretty_inspect}")
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les messages affichés
  #  cf. checker_messages.rb

  # ---------------------------------------------------------------------
  #   MÉTHODES DE CHECK

  # ---------------------------------------------------------------------
  #   Méthode de check de l'icarien
  #   cf. checker_icarien.rb

  # ---------------------------------------------------------------------
  #   Méthodes de check des modules
  #   cf. checker_modules.rb

  # Pour signaler que les corrections ont été confirmés par l'administrateur
  def corrections_confirmed; @corrections_confirmed end

  # Les données de la correction
  # Note : elles sont différentes suivant qu'il s'agit de la confirmation
  # ou de l'exécution (mais je ne sais pas encore si c'est une bonne chose)
  def data_corrections
    @data_corrections ||= begin
      JSON.parse(File.read(fpath_corrections))
    end
  end


end #/<< self
end #/Checker
class << self # Admin


  # ---------------------------------------------------------------------
  #   Méthodes d'helpers (de la class Admin)
  def menu_icariens
    ([[0, 'Choisir l’icarien…']] + User.values_select('all' => true)).in_my_select(id: 'icarien_id', name: 'icarien_id', selected: param(:icarien_id))
  end
end #/<< self
end #/Admin
