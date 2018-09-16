# encoding: UTF-8
=begin

  Script pour changer le pday de benoit en local

=end

PDAY = 10

site.require_objet 'unan'
site.require_objet 'unan_admin'
UnanAdmin.require_module 'set'

benoit = User.get(2)
benoit.unan_set(
  pday: PDAY
)
