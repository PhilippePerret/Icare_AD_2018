# encoding: UTF-8
=begin

Ce module contient des méthodes d'helpers qui peuvent être appelées de
n'importe où dans le site sans avoir à charger les objets auquels elles
s'adressent.

=end

# +params+ doit contenir :objet, :objet_id, :user_id, :processus
def hidden_fields_processus_exec params
  params.merge! r: 'processus/exec'
  params.collect { |name, value| value.to_s.in_hidden(name: name) }.join("\n")
end
