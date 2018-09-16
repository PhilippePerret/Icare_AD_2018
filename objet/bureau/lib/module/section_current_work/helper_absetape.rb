# encoding: UTF-8
Bureau.require_module 'module_methodes_work'
# => module MethodesTravail

class AbsModule
class AbsEtape

  include MethodesTravail

  def liens_edit_if_admin
    user.admin? || (return '')
    '[edit]'.in_a(href: "abs_etape/#{id}/edit")
  end

  # Liste des objectifs, ceux de l'étape elle-même ainsi que
  # ceux de ses travaux-types, formatés comme une suite de div.objectif
  # à insérer directement dans l'étape
  def objectifs_formated
    ([objectif.nil_if_empty]+ travaux_types.objectifs).uniq.compact.collect do |t|
      t.in_div(class: 'container bold italic')
    end.join
  end

  def minifaq_formated
    (site.folder_objet+'abs_minifaq/lib/module/formulaire').require
    drequest = {
      where:    {numero: numero, abs_module_id: self.module_id},
      colonnes: [:content, :user_id]
    }
    hdata = dbtable_minifaq.select(drequest)
    if hdata.empty?
      # Aucune Q/R pour cette étape
      "#{user.pseudo}, soyez #{user.f_la} prem#{user.f_iere} à poser une question sur cette étape de travail.".in_p(class: 'italic')
    else
      hdata.collect do |hminiqr|
        # On indique quand c'est une propre question de l'user courant
        # Ça n'est pas uniquement pour faire joli, c'est aussi pour que
        # l'icarien puisse trouver plus facilement sa réponse.
        classes = ['mf_qr']
        hminiqr[:user_id] && hminiqr[:user_id] == user.id && classes << 'yours'
        hminiqr[:content].in_div(class: classes.join(' '), id: "mf_qr_#{hminiqr[:id]}")
      end.join
    end
  end
  #/minifaq_formated

end #/AbsEtape
end #/AbsModule
