# encoding: UTF-8
class SiteHtml
class << self

  def current
    @current ||= SiteHtml.new
  end

  # Pour les tests (SiteHtml.reset_current)
  def reset_current
    @current = SiteHtml.new
    @current.require_config
    # debug "New site instance: #{@current.object_id}"
  end

end #<< self
end #/SiteHtml

def site
  @_instance_site ||= SiteHtml.current
end
