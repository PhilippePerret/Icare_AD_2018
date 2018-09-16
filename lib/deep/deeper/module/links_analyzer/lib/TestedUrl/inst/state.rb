# encoding: UTF-8
=begin

  Module de méthode par l'état (les méthodes-question) de l'url testée

=end
class TestedPage

  # Retourne TRUE si la page est exclue
  def has_route_excluded?
    if @has_route_excluded === nil
      @has_route_excluded = defined?(EXCLUDED_ROUTES) && EXCLUDED_ROUTES!=nil && EXCLUDED_ROUTES.key?(route)
      TestedPage.routes_exclues_count += 1 if @has_route_excluded
    end
    @has_route_excluded
  end

  def has_folder_excluded?
    if @has_folder_excluded === nil
      @has_folder_excluded = defined?(EXCLUDED_FOLDERS) && EXCLUDED_FOLDERS!=nil && EXCLUDED_FOLDERS.key?(File.dirname(route))
      TestedPage.routes_exclues_count += 1 if @has_route_excluded
      # Si la route doit être exclue, on s'assure quand même qu'elle retourne
      # un statut html de 200 si check_status est true.
      if @has_folder_excluded
        data_folder_exclude = EXCLUDED_FOLDERS[File.dirname(route)]
        if data_folder_exclude[:check_status]
          html_status == 200 || set_invalide
        end
      end
    end
    @has_folder_excluded
  end

  # Retourne TRUE si la route commence par http:// ou https://
  def entete_http?
    !!route.match(/^https?:\/\//)
  end
  # Retourne TRUE si la route commence par http://www.laboiteaoutilsdelauteur.fr
  def full_url_base?
    !!route.start_with?(self.class::BASE_URL)
  end

  # Retourne TRUE si la route est simplement une ancre
  def is_ancre?
    route_init.start_with?('#')
  end

  # Retourne TRUE si l'url se termine par une ancre (mais n'est
  # pas seulement une ancre comme la méthode ci-dessus)
  def url_with_ancre?
    url_anchor != nil && !is_ancre?
  end

  # Retourne TRUE si c'est un lien externe
  def hors_site?
    @is_hors_site = (entete_http? && !full_url_base?) if @is_hors_site === nil
    @is_hors_site
  end

end
