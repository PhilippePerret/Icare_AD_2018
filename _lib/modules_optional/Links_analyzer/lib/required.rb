# encoding: UTF-8
=begin

  Module qui requiert tout ce qui est nécessaire et définit les
  données de base (MAIN_FOLDER)

=end
MAIN_FOLDER = File.dirname(File.dirname(File.expand_path __FILE__))

Dir["#{MAIN_FOLDER}/lib/**/*.rb"].each{|m| require m}
