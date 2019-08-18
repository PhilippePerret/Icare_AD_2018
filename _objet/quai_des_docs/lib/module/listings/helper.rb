# encoding: UTF-8
class IcModule::IcEtape::IcDocument

  # Retourne le fomulaire de téléchargement du document
  # Par exemple pour l'étape de travail.
  #
  # +options+
  #   :infos      Si TRUE, les informations pour le document (module, étape)
  #               sont ajoutées.
  #   mark_if_not_shared:  Si TRUE est que le document n'est pas partagé,
  #                         on renvoie un texte l'indiquant. Sinon, un string
  #                         vide est retourné
  #
  def form_download options = nil
    options ||= Hash.new
    # return (options[:mark_if_not_shared] === false ? "" : mark_non_shared) unless has_documents?

    c = ""
    c << "download".in_hidden(name:'operation')
    c << 1.in_hidden(name:'download[qdd]')
    c << self.id.in_hidden(name:'download[icdocument_id]')
    c << checksum.in_hidden(name: 'download[checksum]')
    c << (owner.pseudo||'Pseudo introuvable').in_div(class: 'doc_auteur')
    c << div_document
    chtml = c.in_form(class: 'doc_qdd inlineblock pointer download', onclick: "this.submit()", action: "quai_des_docs/#{self.id}/download")

    if options[:infos]
      (div_infos + chtml).in_div(class: 'doc_qdd')
    else
      chtml
    end
  end

  # = main =
  #
  # Retourne le code HTML du formulaire qui contient :
  #   SOIT Le formulaire de cotage du document si user ≠ auteur document
  #   SOIT Le formulaire de partage du document si user = auteur document
  #
  # Il est prévu pour s'associer au formulaire de download ci-dessus
  #
  # Pour le moment, les +options+ ne sont pas utilisées.
  #
  def form_cote_or_partage
    if user.id == owner.id # <= Auteur du document
      form_partage
    else # <= Lecteur du document
      form_cotage
    end
  end

  def form_cotage
    # L'user courant a-t-il déjà commenté le document courant
    # Pour la classe du document final (y sera ajouté 'deja_lu' si le document
    # a déjà été coté/commenté)
    class_div = ['cotage_form']
    deja_lu = QuaiDesDocs.table_lectures.count(where: {user_id: user.id, icdocument_id: self.id}) > 0
    if deja_lu
      # => Le document a déjà été coté et commenté
      h = QuaiDesDocs.table_lectures.get(where: {user_id: user.id, icdocument_id: self.id})
      com_id = h[:id]
      coteo = h[:cotes][0]
      coteo = coteo == '-' ? 0 : coteo.to_i
      cotec = h[:cotes][1]
      cotec = cotec == '-' ? 0 : cotec.to_i
      commentaire = h[:comments] || ''
      class_div << 'deja_lu'
    else
      com_id = ''; coteo = 0; cotec = 0; commentaire = ''
    end

    (
      com_id.in_hidden(name: 'com_id') +
      'Cote pour… l’original'.in_span(class: 'libelle')    +
      ([[0, 'Cote…']] + (1..5).collect{|n|[n, n]}).in_select(name: 'cote_original', selected: coteo) +
      ' … le commentaire'.in_span(class: 'libelle') +
      ([[0, 'Cote…']] + (1..5).collect{|n|[n, n]}).in_select(name: 'cote_comments', selected: cotec) +
      commentaire.in_textarea(name: 'comments', placeholder: 'Commentaire textuel') +
      'Enregistrer cotes et commentaire'.in_submit(class: 'btn btn-primary').in_div(class: 'row')
    ).in_form(action: "ic_document/#{id}/set_cote",class: 'container').in_div(class: class_div.join(' '))
  end

  def form_partage
    menu_ori = [['1', 'Partagé'],['2', 'Non partagé']].in_select(name: "doriginal_sharing", selected: (shared?(:original) ? '1' : '2') )
    menu_com = [['1', 'Partagé'],['2', 'Non partagé']].in_select(name: "dcomments_sharing", selected: (shared?(:comments) ? '1' : '2') )
    (
      ( "Original ".in_span + menu_ori) +
      ( "Commentaires".in_span + menu_com) +
      'Définir'.in_submit
    ).in_form(class: 'inline container', action:"ic_document/#{id}/set_partage").in_div(class: 'partage_form')
  end

  # Lorsque c'est l'affichage des documents sur le quai des docs (options[:full]),
  # on indique les informations du document dans un cadre sous le formulaire de
  # download du document.
  def bloc_infos
    (
      'module '.in_span(class: 'libelle') +
      (abs_module_id ? absmodule.name : 'Présentation').in_span(class: 'module') +
      '   étape'.in_span(class: 'libelle') +
      (abs_etape_id  ? "#{absetape.numero} : #{absetape.titre}" : '---').in_span(class: 'etape') +
      ((created_at||time_original).as_human_date(true, true, nil, 'à')).in_span(class: 'date').in_div(class: 'right small')
    ).in_div(class: 'bloc_infos')
  end

  # Retourne un div avec le nom du document et un picto
  # pour le charger en indiquant de quel(s) document(s)
  # il est question, original ou commentaires, ou les
  # deux. Rappel : Ce div n'est utilisé que dans le listing
  # du Quai des docs
  # Note : Si le nom du document est trop long, il est
  # réduit pour que l'affichage soit toujours correct.
  def div_document

    # Nom qui va servir pour l'affichage
    dname = File.basename(original_name, File.extname(original_name))

    doc_name_displayed =
      if dname.length > 50
        name_avant = dname[0..25]
        name_apres = dname[-25..-1]
        "#{name_avant}…#{name_apres}"
      else
        dname
      end.gsub(/_/, ' ')

    arr_docs = Array.new
    arr_docs << "original"      if has?(:original)
    arr_docs << "commentaires"  if has?(:comments)
    arr_docs = arr_docs.pretty_join

    doc_name_displayed << " (#{arr_docs})"

    info_own_documents_always_displayed =
      if user.id == owner.id
        sh = "le document original #{shared?(:original) ? 'est' : 'n’est pas'}  partagé, "
        sh << "le document commenté #{shared?(:comments) ? 'est' : 'n’est pas'}  partagé"
        "(Vos propres documents vous sont toujours montrés, qu’ils soient partagés ou non avec les autres — #{sh})".in_div(class: 'small italic air')
      else '' end

    (
      Dom.img('icones/document_pdf.png', class: 'doc_img') +
      doc_name_displayed.in_span(class: 'doc_name') +
      info_own_documents_always_displayed
    ).in_div class: 'doc_div', title: "Télécharger le document #{doc_name_displayed} (#{arr_docs})…"
  end


end
