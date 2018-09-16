# encoding: UTF-8

# +hdata+ Hash qui peut contenir :
#   :user_id          ID de l'user
#   :user             Instance de l'user
#   :message          Le message exact
#   :created_after    Date après laquelle doit avoir été créée l'actu
#   :created_before   Date avant laquelle doit avoir été créée l'actu
#   :data             Les data éventuelles de l'actualité
#   :count            Le nombre d'actualités à trouver
#
def l_actualite hdata
  require_objet_actualite_if_needed
  TActualite.new hdata
end

def require_objet_actualite_if_needed
  @objet_actualite_is_loaded ||= begin
    site.require_objet 'actualite'
    true
  end
end

class TActualite

  include ModuleTestTimeMethodes
  # attr_reader :created_after, :created_before, :updated_after, :updated_before

  attr_reader :user_id, :user, :message, :data
  attr_reader :count
  def initialize hdata
    hdata.each{|k,v|instance_variable_set("@#{k}",v)}
    user.nil? && user_id != nil && user = User.new(user_id)
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe
    drequest = Hash.new
    where    = Array.new
    user.nil?     || where << "user_id = #{user.id}"
    message.nil?  || where << "message = \"#{message}\""
    data.nil?     || where << "data = \"#{data}\""
    where += where_time_tests
    @count ||= 1

    drequest = {where: where.join(' AND ')}
    nombre = SiteHtml::Actualite.table.count(drequest)
    if nombre == count
      nt = count > 1 ? 'nt' : ''
      success "#{designation.capitalize} existe#{nt}."
    elsif nombre > count
      raise "On trouve #{nombre} actualités présentant les caractéristiques demandées."
    else
      raise "Impossible de trouver #{designation}."
    end
  end

  def designation
    @designation ||= begin
      des = count.to_i > 1 ? "les actualités" : "l'actualité"
      message.nil? || des << " “#{message}”"
      des << times_for_designation
      user.nil? || " concernant #{user.pseudo} (##{user.id})"
      data.nil? || " avec les données #{data}"
      des
    end
  end

end #TActualite
