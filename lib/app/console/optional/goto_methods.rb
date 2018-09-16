# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def app_goto_section section_name
    section_name = section_name.strip
    redirection = case section_name
    when "sceno", "scenodico"       then 'scenodico/home'
    when "dico", "dictionnaire"     then 'scenodico/list'
    when "nouveau_mot"              then 'scenodico/edit'
    when "filmo", "filmodico"       then 'filmodico/home'
    when "nouveau_film"             then 'filmodico/edit'
    when "analyses", "analyse"      then 'analyse/home'
    when /^page narration (.*)$/
      console.require 'narration'
      aller_page_narration section_name.sub(/^page narration/, '').strip
      return nil
    when /^c?narration$/            then 'cnarration/home'
    when /^(dashboard|admin) c?narration$/    then 'admin/dashboard?in=cnarration'
    when 'new_page_narration'       then 'page/edit?in=cnarration'
    # Pour les livres, cf. ci-dessous, ils sont tous traités
    # en même temps
    when 'unanunscript', '1a1s', 'unan'     then 'unan/home'
    when 'unan_admin', 'admin_unan' then 'unan_admin/dashboard'
    # Noter que pour les méthodes ci-dessous, c'est en appelant une
    # méthode "unan new <truc>" que cette méthode est appelée
    when 'unan_new_pday'                        then 'abs_pday/edit?in=unan_admin'
    when 'unan_new_work', 'unan_new_travail'    then 'abs_work/edit?in=unan_admin'
    when 'unan_new_page', 'unan_new_page_cours' then 'page_cours/edit?in=unan_admin'
    when 'unan_new_qcm', 'unan_new_quiz'        then 'quiz/edit?in=unan_admin'
    when 'unan_new_question'                    then 'question/edit?in=unan_admin/quiz'
    when 'unan_new_exemple'                     then 'exemple/edit?in=unan_admin'
    else
      if section_name.start_with?('livre ')
        book_ref = section_name[6..-1].to_sym
        top_require './objet/cnarration/lib/required/constants.rb'
        if Cnarration::SYM2ID.has_key?( book_ref )
          book_id = Cnarration::SYM2ID[book_ref]
          "livre/#{book_id}/tdm?in=cnarration"
        else
          error "Le livre de référence `#{book_ref}` est inconnu dans './objet/cnarration/lib/required/constants.rb'."
        end
      else
        # En dernier recours on tente de le traiter comme une route
        if section_name.match(/^([a-z_]+)\/([0-9]+\/)?(([a-z_]+))$/)
          debug "section name : #{section_name.inspect}"
          sub_log "<a href='#{section_name}'>S'y rendre</a>"
          return nil
        else
          error "La section `#{section_name}` est inconnue où je ne sais pas comment m'y rendre."
          nil
        end
      end
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
