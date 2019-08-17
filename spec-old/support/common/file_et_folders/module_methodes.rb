module MethodesDossiersFichiers
  def existe options = nil
    options ||= Hash.new
    options[:success] ||= "#{designation} existe."
    options[:failure] ||= "#{designation} n'existe pas."
    if File.exist? path
      success options[:success]
    else
      raise options[:failure]
    end
  end
  def nexistepas options = nil
    options ||= Hash.new
    options[:success] ||= "#{designation} n'existe pas."
    options[:failure] ||= "#{designation} ne devrait pas exister."
    if File.exist? path
      raise options[:failure]
    else
      success options[:success]
    end
  end
end
