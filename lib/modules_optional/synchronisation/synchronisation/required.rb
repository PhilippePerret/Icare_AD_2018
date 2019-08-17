# encoding: UTF-8
FOLDER_SYNCHRONISATION = File.expand_path(File.dirname(__FILE__))

Dir["#{FOLDER_SYNCHRONISATION}/required/**/*.rb"].each{ |m| require m }