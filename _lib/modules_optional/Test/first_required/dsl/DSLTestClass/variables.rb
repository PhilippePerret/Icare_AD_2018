# encoding: UTF-8
class DSLTestMethod

  def let var_name, &block
    !self.respond_to?(var_name) || raise("Le nom de variable #{var_name.inspect} est impossible : C'est une méthode existante.")
    SiteHtml::TestSuite.set_variable var_name, &block
  end

  def tget var_name
    SiteHtml::TestSuite.get_variable var_name
  end
end
