# encoding: UTF-8
=begin

  Les méthodes ou objets utilisables par les fichiers de test

=end
class DSLTestMethod

  if defined?(ModuleCaseTestMethods)
    # Sinon, il sera inclus après le chargement du module
    include ModuleCaseTestMethods
  end

  # Pour décrire plus précisément le test
  def description str = nil
    if str.nil?
      @tdata[:description]
    else
      @tdata[:description] = str
    end
  end
end
