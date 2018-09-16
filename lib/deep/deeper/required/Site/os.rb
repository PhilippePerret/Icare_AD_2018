# encoding: UTF-8
=begin

  Extension de la classe SiteHtml pour gérer l'operating system
  de l'user et notamment savoir s'il est sur windows ou sur Mac
  ou sur Unix

=end
class SiteHtml

  def os
    @os ||= begin
      case true
      when windows? then 'Windows'
      when apple?   then 'Apple'
      when unix?    then 'Unix'
      end
    end
    debug "@os : #{@os.inspect}"
    debug "windows? #{windows?.inspect} / apple? #{apple?.inspect} / unix? #{unix?.inspect}"
    @os
  end

  def os_path arr
    arr.join(os_delimiter)
  end

  def os_delimiter
    @delimiter_by_os ||= begin
      case true
      when apple?, unix? then '/'
      when windows? then '\\'
      end
    end
  end
  alias :os_delimiteur :os_delimiter
  alias :os_delimitor :os_delimiter

  def os_folder_documents
    @os_folder_documents ||= begin
      case true
      when apple?   then "/Utilisateurs/#{user.pseudo}/Documents"
      when windows? then "C:\\Users\\#{user.pseudo}\\Documents"
      when unix?    then 'Documents'
      end
    end
  end

  def windows?
    @is_windows = ENV['HTTP_USER_AGENT'].match(/Windows/) != nil if @is_windows === nil
    @is_windows
  end

  def apple?
    @is_apple = ENV['HTTP_USER_AGENT'].match(/Macintosh/) != nil if @is_apple === nil
    @is_apple
  end
  alias :mac? :apple?

  def unix?
    !windows? && !apple?
  end

end
