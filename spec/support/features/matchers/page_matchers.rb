require 'rspec/expectations'

RSpec::Matchers.define :be_home_page do
  match do |page|
    page.has_css?('span', {id:'titre_site', text: 'Atelier Icare'})
  end
  description do
    "On se trouve bien sur la page d'accueil."
  end
  failure_message do |page|
    "On devrait être sur la page d'accueil. On se trouve sur une page ayant pour contenu #{page.html}"
  end
  failure_message_when_negated do
    "On ne devrait pas se trouver sur la page d'accueil"
  end
end

RSpec::Matchers.define :be_burea_page do
  match do |page|
    page.has_css?('h1', {text: 'Votre bureau'})
  end
  description do
    "On se trouve bien dans le bureau de l'icarien."
  end
  failure_message do |page|
    "On devrait être dans le bureau de l'icarien. On se trouve sur une page ayant pour contenu #{page.html}"
  end
  failure_message_when_negated do
    "On ne devrait pas se trouver dans le bureau de l'icarien."
  end
end
