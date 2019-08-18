# encoding: UTF-8
def icetape
  @icetape ||= IcModule::IcEtape.new(objet_id)
end


# Retourne les instances IcDocument des documents de l'étape,
# mais noter que c'est après que les documents aient été
# enregistrés (cette méthode sert aux mails)
def documents_etape
  @documents_etape ||= begin
    site.require_objet 'ic_document'
    icetape.documents.split(' ').collect do |doc_id|
      doc_id = doc_id.to_i
      IcModule::IcEtape::IcDocument.new doc_id
    end
  end
end

def get_send_work_error
  # debug "[get_send_work_error] app.session['send_work_error'] = #{app.session['send_work_error'].inspect}"
  app.session['send_work_error'] != nil || (return Hash.new)
  hdepart = JSON.parse(app.session['send_work_error']).to_sym.nil_if_empty
  hdepart != nil || (return Hash.new)
  hfin = Hash.new
  hdepart.each { |k, v| hfin.merge!(k.to_s.to_i => v) }
  # app.session['send_work_error'] = nil
  hfin
end
