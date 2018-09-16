# encoding: UTF-8

defined?(Bureau) || site.require_objet('bureau')
Bureau.require_module 'module_methodes_work'

class AbsModule
class AbsEtape
class AbsTravailType

  include MethodesTravail
  # => Notamment travail_formated

end #/AbsTravailType
end #/AbsEtape
end #/AbsModule
