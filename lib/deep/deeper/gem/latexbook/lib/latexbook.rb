# encoding: UTF-8

# Pour le moment, ce "pseudo-gem" est pleinement dépendant
# du site RestSite qui le contient, ça ne peut pas être un
# gem indépendant


FOLDER_LATEXBOOK = File.dirname __FILE__

['class', 'instance'].each do |subfolder|
  if RUBY_VERSION.to_i >= 2
    require_relative "latexbook/#{subfolder}"
  else
    require File.join(FOLDER_LATEXBOOK, 'latexbook', subfolder)
  end
end
