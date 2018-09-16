# encoding: UTF-8
class Admin
class Mailing
class << self

  # Retourne le code du premier message formaté (pour confirmation)
  #
  # En fait : deux messages, l'un pour une femme et l'autre pour un
  # homme
  def first_message
    'Version Femme'.in_h4 +
    real_message_for(User.new(2)) + # féminin
    'Version Home'.in_h4 +
    real_message_for(User.new(1))   # masculin
  end

  # Retourne le message réel pour l'icarien de donnée +udata+
  #
  # +u+ Instance {User} de l'icarien à qui il faut envoyer le message
  def real_message_for u
    u.instance_of?(User) || (raise "Le premier paramètre de `real_meassage_for` devrait être un User… Le paramètre est de type #{u.class}")
    data_replacement = {}

    mess =
    # Seulement si on ne demande pas de laisser les %
    if template?
      variables_template.each do |key, dkey|
        value =
          if dkey[:replace].nil?
            u.send(key)
          else
            dkey[:replace]
          end
        data_replacement.merge! key => value
      end
      data_replacement[:pseudo] = data_replacement[:pseudo].capitalize
      # template_formated % data_replacement
      template_formated.gsub(/%\{(.*?)\}/){
        tout = $&
        balise = "#{$1}".to_sym
        if data_replacement.key? balise
          data_replacement[balise]
        else
          tout
        end
      }
    else
      template_formated.gsub(/%\{pseudo\}/, u.pseudo.capitalize)
    end

    # Déserbage du code si nécessaire
    if code_erb?
      # On indique que tous les liens doivent être définis pour
      # le site distant
      lien.all_link_to_distant = true
      code_final = ERB.new(mess).result(u.bind)
      lien.all_link_to_distant = nil
      code_final
    else
      mess
    end
  end
  # /real_message_for

  # Définit les variables template
  #
  #
  def variables_template
    @variables_template ||= begin
      {
        :votre_bureau => {key: :votre_bureau, replace: lien.bureau('votre bureau'), description: "Lien vers le bureau"},
        :mail         => {key: :mail, replace: nil, description: "Pour insérer le mail de l'icarien"},
        :pseudo       => {key: :pseudo, replace: nil, description: "Pour insérer le pseudo de l'icarien"},
        :date         => {key: :date, replace: Time.now.to_i.as_human_date, description: "La date courante (#{Time.now.to_i.as_human_date})"}
      }
    end
  end

  def template_formated
    @template_formated ||= traite_message
  end

  # = Main =
  #
  # Méthode principale qui formate le message
  #
  # Prend le message initial (@message) et compose un
  # template (variables %)
  #
  # Noter que les balises ERB ne sont pas traitées ici, elles ne le
  # seront qu'à la toute fin, au moment d'envoyer le message à un
  # icarien particulier (entendu que ces balises peuvent concerner
  # l'icarien en particulier, son module, son mail, etc.).
  #
  def traite_message
    res = message
    return nil if res.nil? || res.to_s == ""

    unless code_brut? || code_erb?
      # Correction des doubles retours chariot
      res = res.split("\n").collect { |e| e.strip }.join("\n")
      res = res.split("\n\n").collect { |l| "<p>#{l.strip}</p>" }.join('')
      # Retours de chariot simples
      res = res.split("\n").collect { |line| line.strip }.join('<br />')
    end

    signature = signature_bot? ? "Le Bot de l'atelier" : "Phil, pédagogue de l'atelier"
    res = "<p>Bonjour %{pseudo},</p>#{res}<p>#{signature}</p>"

    return res
  end
  # /traite_message

end #/<< self
end #/Mailing
end #/Admin
