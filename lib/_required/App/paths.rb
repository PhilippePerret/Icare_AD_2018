# encoding: UTF-8
=begin
  Scories de l'ancien atelier ?
=end
class App

  def debug_path
    @debug_path ||= File.join(debug_folder,'debug.log')
  end

  def debug_folder
    @debug_folder || begin
      d = File.join('.','tmp','debug')
      File.exists?(d) || `mkdir -p "#{d}"`
      d
    end
  end
end #/App
