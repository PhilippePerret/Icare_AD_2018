# encoding: UTF-8
# raise_unless( (user.admin? || user.icarien?), nil, identification = true )
raise_unless_identified
class User
  # RETURN true si l'user possède un module à démarrer
  def has_module_to_start?
    where = "user_id = #{self.id} AND SUBSTRING(options,1,1) = '0'"
    dbtable_icmodules.count(where: where) > 0
  end
end
class Bureau
class << self

  # La section du bureau quand c'est un administrateur
  def section_administrateur
    Bureau.require_module 'bureau_admin'
    _section_administrateur
  end

  # Section principale indiquant le statut de
  # l'auteur (reçu, en attente, actif, inactif, etc.).
  def section_statut_auteur
    (
      bouton_votre_travail_if_needed +
      (
        "Statut".in_span(class: 'title') +
        "#{user.hstatut}".in_span(class: 'user_state')
      ).in_div(id: 'div_user_state')
    ).in_div(id: 'section_statut')
  end

  def bouton_votre_travail_if_needed
    user.actif? || (return '')
    'Votre travail'.in_a(href: 'bureau/home#travail_etape', class: 'small btn fright')
  end

  # Section principale contenant les notifications de
  # l'auteur, pour remettre son travail, télécharger ses
  # commentaires, payer son module, etc.
  def section_notifications
    user.watchers.as_ul # !Différent de String#as_ul
  end

  # ====================================
  #   BLOC D'INFORMATION SUR LE MODULE
  # ====================================
  def section_info_module_et_echeance
    if user.actif?
      Bureau.require_module 'infos_module'
      Bureau.require_module 'infos_etape'
      _fs_module_courant +
      _fs_etape_courante
    elsif user.en_pause?
      'Vous êtes en pause, vous pouvez redémarrer votre module à tout moment en cliquant sur le bouton ci-dessus.'.in_div(class: 'small italic') +
      'Redémarrer le module'.in_a(href: "ic_module/#{user.icmodule.id}/restart", class: 'btn')
    else
      "Bienvenue dans votre bureau".in_div(class: 'big left', style:'margin: 2em 0 1.5em') +
      if user.recu?
        if user.has_module_to_start?
          'Vous pouvez démarrer votre module pour le commencer.'.in_div
        else
          dhisto    = {href: "bureau/historique"}
          dcommand  = {href: "abs_module/list"}
          doutils   = {href: "bureau/outils"}
          "Depuis votre bureau, vous pouvez (*) :".in_div +
          (
            'Consulter l’historique de votre travail'.in_a(dhisto).in_li +
            'Commander un nouveau module'.in_a(dcommand).in_li +
            'Utiliser encore les outils de l’atelier'.in_a(doutils).in_li
          ).in_ul +
          '(*) Notez que vous pouvez à tout moment atteindre ces liens depuis les menus sous le titre de votre présent bureau.'.in_div(class: 'small italic')
        end
      else
        # Pour un icarien qui n'est pas encore reçu
        'Lorsque votre candidature sera validée, vous pourrez trouver ici toutes les informations sur votre travail au sein de l’atelier Icare.'.in_p
      end
    end
  end
  # Section principale contenant le travail de l'auteur,
  # son échéance, etc.
  # ==============================================
  #  CONSTRUCTION DE LA PAGE AFFICHANT LE TRAVAIL
  # ==============================================
  def section_travail_auteur
    user.actif? || (return '')
    Bureau.require_module 'section_current_work'
    _section_current_work
  end

end #<< self
end #/Bureau
