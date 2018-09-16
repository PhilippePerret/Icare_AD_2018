# encoding: UTF-8
class IcModule
class IcEtape
class << self

  # cf. le module 'create'
  def create_for icmod, numero
    IcModule::IcEtape.require_module 'create'
    _create_for icmod, numero
  end

end #/<< self
end #/ IcEtape
end #/ IcModule
