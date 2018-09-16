# encoding: UTF-8
class Admin
class Taches
class Tache

  # Pour afficher la tâche dans un listing comme celui présenté
  # sur la page admin/taches.erb de l'administrateur
  def as_li
    (
      bouton_ok +
      div_tache +
      div_infos_tache
    ).in_li(class: li_class.join(' '))
  end

  # Définit la class css en fonction du state de la
  # tâche
  def li_class
    css = ['tache']
    if state > 5 # très importante
      css << 'prioritaire'
    elsif state > 2
      css << 'important'
    end
    css
  end

  def div_tache
    @div_tache ||= begin
      dt = "#{tache}"
      if file
        # Soit le path est un chemin d'accès à un fichier, soit c'est
        # une route. On crée le lien en fonction
        expath = File.expand_path(file)
        link =
          if File.exist? expath
            lien.edit_file(expath, titre: "ouvrir le fichier associé")
          else
            "se rendre à #{file}".in_a(href:file)
          end
        dt << " (#{link})"
      end
      # /s'il y a un path
      dt.in_span(class:'tache')
    end
  end
  def div_infos_tache
    (
      id_de_la_tache +
      echeance_humaine +
      admin_humain
    ).in_div(class:'infos_tache')
  end
  def id_de_la_tache
    "Tâche ##{id}".in_span
  end
  def echeance_humaine
    @echeance_humaine ||= begin
      if echeance.nil?
        "Pas d'échéance".in_span
      else
        css_reste, message_reste = reste_humain
        (
          "Échoue le <strong>#{echeance.as_human_date}</strong>".in_span(class:'date') +
          message_reste.in_span(class:"reste #{css_reste}")
        ).in_span
      end
    end
  end

  # Renvoie le texte indiquant le nombre de jours restants ou
  # le nombre de jour de dépassement en mettant la couleur suivant
  # l'état de la tâche
  def reste_humain
    nb = nombre_jours_before_echeance.freeze
    if nb.nil?
      ['', ""]
    elsif nb == 0
      ['today', "aujourd'hui"]
    elsif nb > 0
      ['later', "à faire dans #{nb} jour#{nb>1 ? 's' : ''}"]
    elsif nb < 0
      nb = - nb
      ['over', "la tâche aurait dû être faite depuis #{nb} jour#{nb > 1 ? 's' : ''}"]
    end
  end

  def admin_humain
    return "" if admin_id == user.id
    @admin_humain ||= "#{admin.pseudo}".in_span(class:'owner')
  end
  def bouton_ok
    "OK".in_a(href:"admin/taches?op=stop_tache&tid=#{id}").in_span(class:'btnok')
  end

end #/Tache
end #/Taches
end #/Admin
