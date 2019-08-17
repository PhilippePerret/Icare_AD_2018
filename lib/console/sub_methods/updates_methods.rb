# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def exec_updates params
    case params
    when /^delete ([0-9]+)$/
      # Pour détruire une actualisation
      update_id = params.split(' ')[1].to_i
      tbl = site.dbM_table(:cold, 'updates')
      if tbl.get(update_id).nil?
        error "L'update ##{update_id} n'existe pas, impossible de la détruire."
      else
        tbl.delete(update_id)
        flash "Update ##{update_id} détruite avec succès."
      end
    when /^show$/
      redirect_to 'site/updates'
    when /^show online$/
      flash "Pas encore implémenté"
    else
      site.new_update(Data::by_semicolon_in( params ))
    end
    return ""
  end

end #/Console
end #/Admin
end #/SiteHtml
