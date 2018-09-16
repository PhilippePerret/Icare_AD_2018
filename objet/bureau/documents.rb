# encoding: UTF-8
raise_unless_identified


# = main =
#
# Méthode principale pour afficher la liste des documents QDD de
# l'user courant
#
# Avant, c'était la route 'quai_des_docs/list' qui était utilisée
def liste_documents_quai_des_docs
  if has_documents_qdd?
    site.require_objet 'quai_des_docs'
    QuaiDesDocs.require_module 'listings'
    filtre_docs = {user_id: user.id}
    QuaiDesDocs.as_ul(filtre: filtre_docs.dup, full: true, avertissement: false)
  else
    'Vous n’avez aucun document déposé sur le Quai des docs de l’atelier.'.in_p(class: 'italic')
  end
end

def has_documents_qdd?
  dbtable_icdocuments.count(where: "user_id = #{user.id} AND (SUBSTRING(options,6,1) = '1' OR SUBSTRING(options,14,1) = '1')") > 0
end

# = main =
#
# Méthode faisant la liste des derniers documents commentés et
# permettant de les recharger
def liste_derniers_documents_commented
  if has_documents_commented?
    site.require_objet 'ic_etape'
    downloads.collect do |hdown|
      icetape = IcModule::IcEtape.new(hdown[:icetape_id])
      module_short_name =
      new_name = "Commentaires_etape_#{icetape.abs_etape.numero}_module_#{icetape.abs_etape.abs_module.module_id.capitalize}"
      titre = "Commentaires de l’#{icetape.designation}"
      titre.
        in_a(href: "bureau/documents?op=download&p=#{CGI.escape hdown[:folder]}&n=#{new_name}").
        in_li(class: 'folder_comments')
    end.join.in_ul(id: 'ul_uploaded_comments')
  else
    'Vous n’avez eu aucun document commenté au cours du mois qui précède.'.in_p(class: 'italic')
  end
end

# Retourne TRUE si des documents sont trouvés dans le dossier temporaire
# des download
def has_documents_commented?
  downloads.count > 0
end


# RETURN une liste de Hash qui contiennent {:icmodule_id, :icetape_id, :folder}
# qui définissent chaque dossier commentaire trouvé
def downloads
  # "download/owner-#{owner.id}-upload_comments-#{owner.icmodule.id}-#{icetape.id}"
  @downloads ||= begin
    Dir["./tmp/download/owner-#{user.id}-upload_comments-*"].collect do |fpath|
      o, uid, uc, icmodule_id, icetape_id = File.basename(fpath).split('-')
      {icmodule_id: icmodule_id.to_i, icetape_id: icetape_id.to_i, folder: fpath}
    end
  end
end

case param(:op)
when 'download'
  folder_path = param(:p).nil_if_empty
  folder_name = param(:n).nil_if_empty
  folder_path != nil || raise('Vous essayez de pirater le site ?')
  folder_name != nil || raise('Vous essayez de pirater le site, c’est vraiment ça ?')
  new_path = File.join(File.dirname(folder_path), folder_name)
  File.exist?(new_path) || FileUtils.cp_r(folder_path, new_path)
  rf = SuperFile.new(new_path)
  rf.download
end
