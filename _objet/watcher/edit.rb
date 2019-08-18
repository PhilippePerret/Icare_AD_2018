# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Watcher
  class << self

    # Création du watcher
    def create
      data_valides? || return
      now = Time.now.to_i
      id = dbtable_watchers.insert(
        user_id: @user_id, objet: @objet, objet_id: @objet_id, processus: @processus, triggered: @triggered, data: @data,
        created_at: now, updated_at: now
      )
      flash "Watcher ##{id} créé avec succès."
    end

    # Produit une erreur et retourne FALSE si la donnée n'est pas valide
    def data_valides?

      @user_id = wparam[:user_id].nil_if_empty
      @user_id != nil && @user_id.numeric? || (raise 'user_id doit absolument être défini')
      @user_id = @user_id.to_i
      @user_id != 1 || (raise 'user_id ne peut pas être Phil.')

      @objet = wparam[:objet].nil_if_empty
      @objet != nil || (raise 'Il faut définir l’objet.')

      @objet_id = wparam[:objet_id].nil_if_empty
      @objet_id != nil && @objet_id.numeric? || (raise 'objet_id doit être défini et être un nombre.')
      @objet_id = @objet_id.to_i

      @processus = wparam[:processus].nil_if_empty
      @processus != nil || (raise 'Le processus doit obligatoirement être défini.')

      @triggered = wparam[:triggered].nil_if_empty
      @triggered.nil? || begin
        @triggered.numeric? || (raise 'Le triggered doit être un nombre (timestamp de secondes)')
        @triggered = @triggered.to_i
      end

      @data = wparam[:data].nil_if_empty

    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

    # Paramètre du watcher
    def wparam ; @wparam ||= param(:watcher) end

  end #/<< self

end#/Watcher
end#/SiteHtml

case param((:opwatcher))
when 'creer_watcher'
  # = CREATION DU WATCHER =
  SiteHtml::Watcher.create
when 'get_processus_list'
  # = AJAX =
  # => Doit retourner en ajax la liste des processus de l'objet param(:objet)
  processus_list =
    Dir["#{site.folder_objet}/#{param(:objet)}/lib/_processus/*"].collect do |fproc|
      File.basename(fproc)
    end
  Ajax << {processus_list: processus_list.join(' ')}
when 'get_objet_id_list'
  # = AJAX =
  # => Retourne la liste des IDs des objets de type `objet`
  # Si `user_id` est défini, l'objet doit appartenir à l'user
  user_id = param(:user_id).nil_if_empty
  objet   = param(:objet)
  table, prop_titre =
    case objet
    when 'abs_module'   then [dbtable_absmodules, :name]
    when 'bureau', 'quai_des_docs', 'user'     then [nil, nil]
    when 'abs_etape'    then [dbtable_absetapes, :titre]
    when 'ic_module'    then [dbtable_icmodules, nil]
    when 'ic_etape'     then [dbtable_icetapes, nil]
    when 'ic_document'  then [dbtable_icdocuments, :original_name]
    else [nil, nil]
    end
  debug "table: #{table.name} / prop_titre: #{prop_titre}"
  if table.nil?
  else
    dreq = {colonnes: []}
    prop_titre.nil? || dreq[:colonnes] << prop_titre
    user_id.nil? || objet.start_with?('abs_') || dreq.merge!(where:{user_id: user_id.to_i})
    debug "dreq = #{dreq}"
    values =
      table.select(dreq).collect do |hobjet|
        tit = hobjet[prop_titre]
        tit.nil? || tit = CGI.escape(tit[0..20])
        [hobjet[:id], tit]
      end
    debug "values : #{values.inspect}"
    Ajax << {objet_id_list: values.to_json}
  end
when 'user_list'
  # = AJAX =
  type = param(:user_type)
  whereclause =
    case type
    when 'all'
      nil
    when 'actif'
      "SUBSTRING(options,17,1) = '2'"
    when 'inactif'
      "SUBSTRING(options,17,1) = '4'"
    when 'enpause'
      "SUBSTRING(options,17,1) = '3'"
    end
  user_list =
    dbtable_users.select(where: whereclause, colonnes:[:pseudo]).collect do |huser|
      [huser[:id], huser[:pseudo]]
    end
  Ajax << {user_list: user_list.to_json}
end
