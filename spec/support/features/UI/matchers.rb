require 'rspec/expectations'

RSpec::Matchers.define :have_message do |msg|
  match do |page|
    page.has_css?('div#flash div#notices div.notice', text: msg)
  end
  description do
    "La page contient bien le message «#{msg}»."
  end
  failure_message do
    "La page devrait contenir le message «#{msg}»."
  end
  failure_message_when_negated do
    "La page ne devrait pas contenir le message «#{msg}»."
  end
end

RSpec::Matchers.define :have_error do |msg|
  match do |page|
    page.has_css?('div#flash div#errors div.error', text: msg)
  end
  description do
    "La page contient bien l'erreur «#{msg}»."
  end
  failure_message do
    "La page devrait contenir le message d'erreur «#{msg}»."
  end
  failure_message_when_negated do
    "La page ne devrait pas contenir le message d'erreur «#{msg}»."
  end
end
