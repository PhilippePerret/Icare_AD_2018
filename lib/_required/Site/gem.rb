# encoding: UTF-8
class SiteHtml

  # Requérir un gem dans le dossier .gems (qui se trouve
  # hors de la racine du site, en local comme sur alwaysdata)
  def require_gem gem_name, version = nil
    FakeGem::new(gem_name, version).require_gem
  rescue Exception => e
    error "Impossible de requérir le gem #{gem_name} (version #{version}) : #{e.message}"
  end

  # Pour requérir un gem dans le dossier ./lib/Gems
  def require_deeper_gem folder_name
    gem_name = folder_name.split('-')[0]
    $LOAD_PATH << "./lib/Gems/#{folder_name}/lib"
    require gem_name
  end
end
