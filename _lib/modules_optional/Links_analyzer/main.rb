# encoding: UTF-8
=begin

  Pour lancer ce script :
    Dans Atom :         CMD + i
    Dans TextMate :     CMD + r
    Dans le terminal (meilleure solution):
      > cd /Users/philippeperret/Sites/WriterToolbox/lib/deep/deeper/module/links_analyzer
      > ruby main.rb

  Fichier principal qui doit être appelé.

  La première partie contient des choses qui doivent être définies
  en fonction du site courant.

=end

require 'rspec-html-matchers'
require 'capybara/rspec'
include RSpecHtmlMatchers

require_relative 'lib/required'

TestedPage.init
if TestedPage.aide?
  TestedPage.help
elsif TestedPage.run
  TestedPage.report
end
