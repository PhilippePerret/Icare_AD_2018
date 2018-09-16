# encoding: UTF-8
class SuperFile
  
  attr_reader :path
  
  attr_accessor :errors
  

  # {String} File path (note: not expanded)
  def to_s;   @path end

  # {String} Implicite conversion
  def to_str; @path end

  # {String} File name
  def name
    @name ||= File.basename(path)
  end
  
  # {String} File extension
  def extension
    @extension ||= File.extname(name)[1..-1] # sans le "."
  end

  # {String} File affixe (name without extension)
  def affixe
    @affixe ||= File.basename( name, File.extname(name) )
  end

  # {SuperFile} File dirname
  def dirname
    @dirname ||= (SuperFile::new File.dirname( path ))
  end
  alias :folder :dirname
    

  # {Fixnum|Bignum} File/folder size
  def size
    if exist?
      File.stat(path).size
    else
      add_error ERRORS[:inexistant] % {path: path}
      nil
    end
  end
  
  # {Time} Last modification time
  def mtime
    if exist?
      File.stat(path).mtime
    else
      add_error ERRORS[:inexistant] % {path: path}
      return nil
    end
  end
 
  # {Binding} Set bindee for ERB (=> @bind)
  def set_binding foo
    foo = foo.bind unless foo.class == Binding
    @bind = foo
  end
 
end