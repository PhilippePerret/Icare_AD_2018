# encoding: UTF-8
=begin

  Module de méthodes partagées par les AbsEtapes et les AbsTravauxTypes
  pour construire le travail

=end
module MethodesTravail

  site.require_module 'kramdown'

  # {String} Le travail de l'étape, formaté
  def travail_formated
    w = (travail || '').formate_balises_propres
    w = ERB.new(w).result(self.bind)
    w = w.kramdown(owner: nil, output_format: :html) rescue nil
    return w
  rescue Exception => e
    debug e
    send_error_to_admin(exception: e)
    '[IMPOSSIBLE D’AFFICHER LE TRAVAIL]'.in_p(class: 'red')
  end

  # {String} Code HTML pour afficher les liens de l'étape et
  # des travaux-type
  def liens_formated
    (liens.force_encoding('utf-8').split("\n") + travaux_types.liens).collect do |dlink|
      dlink.nil_if_empty != nil || next
      # Plusieurs formats de mail ont été injectés au cours
      # des différentes versions de l'atelier.
      formate_link( dlink ).in_div
    end.compact.join.in_p
  rescue Exception => e
    debug e
    send_error_to_admin(exception: e)
    '[IMPOSSIBLE DE FORMATER LES LIENS]'.in_p(class: 'red')
  end

  def formate_link dlink
    page, titre = nil, nil
    titre, href =
      if (res = dlink.match(/^([0-9]{1,4})::(livre|collection)(::(.*))?$/))
        page  = res[1]
        type  = res[2]
        titre = res[4]

        case type
        when 'livre'
          href = "http://www.scenariopole.fr/narration/page/#{page}"
          [titre, href]
        when 'collection'
          # cf. N0001
           href = "http://www.scenariopole.fr/narration/page/#{page}"
           if user.actif?
             #  TODO CORRIGER
             href += "?fromicare=1&cpicare=#{user.cpassword}&micare=#{user.mail}&idicare=#{user.id}&picare=#{user.pseudo}"
             href += "&xicare=#{user.sexe}"
           end
          [((titre || "[titre de page non défini]") + " (collection NARRATION)"), href]
        end
      else
        # Un lien externe explicite
        # "<url>::<titre lien>"
        href, titre = dlink.split('::')
        href.start_with?('http://') || href.prepend("http://")
        [titre, href]
      end

    titre.in_a(href: href, target: :new)

  end

  # {String} Code HTML pour afficher la méthode de travail si elle
  # est définie.
  def methode_formated
    met = ERB.new(methode).result(self.bind)
    met = met.kramdown(owner: nil, output_format: :html) rescue nil
    return met
  rescue Exception => e
    debug e
    send_error_to_admin(exception: e)
    '[IMPOSSIBLE DE FORMATER LA MÉTHODE]'.in_p(class: 'red')
  end

end
