=begin

  Test de l'affichage des activités sur la page d'accueil

=end
def file_actus; SuperFile.new(site.file_last_actualites.to_s) end

feature "Activités sur la page d'accueil" do

  # Crée un certain nombre d'actualités
  def liste_actualites nombre = 20
    nombre.times.collect do
      cat = Time.now.to_i - (5000 * rand(100))
      {
        user_id: nil, message: "Un message #{rand(100)} à #{cat}",
        created_at: cat
      }
    end
  end

  def create_liste_actualites nombre = 20
    liste_actualites(nombre).collect do |dactu|
      aid = dbtable_actualites.insert(dactu)
      dactu.merge!(id: aid)
    end
  end

  scenario 'Les activités sont correctement affichées sur la page d’accueil' do

    test 'Existence du div, du titre et de la liste'
    visit_home
    La feuille contient la balise 'div', id: 'div_last_actualites'
    La feuille contient la balise 'legend', dans: 'div#div_last_actualites', text: 'Dernières activités'
    La feuille contient la liste 'last_actualites'

  end

  scenario 'Quand il n’y a aucune actvitié' do

    test 'Avec aucune actualité, et aucun listing, on affiche un texte'

    # On détruit tout
    sf = file_actus
    sf.exist? && sf.remove
    dbtable_actualites.delete

    visit_home
    La feuille contient la liste 'last_actualites'
    ul_jid = 'ul#last_actualites'
    La feuille contient la balise 'li', dans: ul_jid, text: 'Aucune activité pour le moment.'
  end

  scenario 'Sans nouvelle activité on n’actualise pas le fichier' do

    test 'Sans nouvelle activité on n’actualise pas le fichier'

    site.require_objet 'actualite'
    actualites = create_liste_actualites 10
    sf = file_actus
    sf.exist? && sf.remove
    # Pour créer le fichier
    visit_home
    expect(sf).to be_exist
    success 'Le fichier HTML du listing des actualités existe.'
    ctime = file_actus.mtime.to_i
    sleep 2
    visit_home
    expect(sf.mtime.to_i).to eq ctime
    success 'Le fichier n’a pas été actualisé.'
  end

  scenario 'Une nouvelle actualité entraine l’actualisation du fichier' do
    test 'Une nouvelle actualité entraine l’actualisation du fichier'


    visit_home
    ctime = file_actus.mtime.to_i.freeze
    sleep 2
    # new_actus = create_liste_actualites 4
    site.require_objet 'actualite'
    last_message = "Dernier message du #{Time.now}"
    SiteHtml::Actualite.create(user_id: benoit, message: last_message)

    visit_home
    expect(file_actus.mtime.to_i).to be > ctime
    success 'Le fichier HTML des actualités a été actualisé.'
    La feuille contient la balise 'span', dans: 'li.actu', text: last_message

  end

  scenario 'Le listing contient les éléments voulus' do

    dbtable_actualites.delete
    sf = file_actus
    sf.exist? && sf.remove
    liste_actus = create_liste_actualites 10

    expect(file_actus).not_to be_exist

    visit_home

    expect(file_actus).to be_exist

    La feuille contient la liste 'last_actualites'
    ul_jid = 'ul#last_actualites'

    liste_actus.each do |dactu|
      aid = dactu[:id]
      La feuille contient la balise 'li', id: "actu-#{aid}", dans: ul_jid
      La feuille contient la balise 'span', class: 'date', dans: "li#actu-#{aid}", text: dactu[:created_at].as_human_date(false, true, '')
      La feuille contient la balise 'span', class: 'message', dans: "li#actu-#{aid}", text: dactu[:message]
    end

  end
end
