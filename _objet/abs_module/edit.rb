# encoding: UTF-8
raise_unless_admin

AbsModule.require_module 'helper_methods'

def absmodule_id
  @absmodule_id ||= site.current_route.objet_id || 1
end
def absmodule
  @absmodule ||= AbsModule.new(absmodule_id)
end


class AbsModule
  def save
    data_valides? || return
    if id.nil?
      @id = table.insert(dparam)
      table_online.insert(dparam.merge(id: @id))
    else
      table.update(id, dparam)
      self.class.table_online.update(id, dparam)
    end
    flash "Module ##{id} (#{name}) sauvé avec succès (online/offline)."
  end
  def data_valides?
    dparam[:name]               = check_non_nil(:name)
    dparam[:module_id]          = check_non_nil(:module_id)
    dparam[:short_description]  = check_non_nil(:short_description)
    dparam[:long_description]   = check_non_nil(:long_description)
    dparam[:tarif]              = check_non_nil(:tarif).to_i
    dparam[:nombre_jours]       = check_non_nil(:nombre_jours).to_i
    dparam[:hduree]             = check_non_nil(:hduree)

    param(:absmodule => dparam)
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  def check_non_nil prop
    val = dparam[prop].nil_if_empty.gsub(/\r\n/,"\n")
    val != nil || raise("La propriété #{prop.inspect}")
    val
  end

  def dparam
    @dparam ||= param(:absmodule)
  end
end

case param(:operation)
when 'save'
  if param(:create_new_module) == 'on'
    @absmodule = AbsModule.new
  end
  absmodule.save
end
