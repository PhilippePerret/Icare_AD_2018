# encoding: UTF-8
=begin

Données pour la table des matières

=end
class Aide

  DATA_TDM = {
    # ---------------------------------------------------------------------
    'site'              => { hname:'Le Site de l’atelier', titre:true},
    1       => { hname: 'Où aller après l’identification'},
    4       => { hname: 'Fréquence des mails d’activité'},
    # ---------------------------------------------------------------------

    'inscription'       => {hname: 'Inscription', titre: true},
    20      => {hname: 'Poser sa candidature'},
    100     => {hname: 'Documents de présentation'},

    'interface'          => { hname:"L'Interface", titre:true},

    # ---------------------------------------------------------------------
    # Tout ce qui concerne le travail sur un module
    'module_apprentissage' => {hname: 'Modules d’accompagnement et d’apprentissage', titre: true},
    200 => {hname: 'Liste et tarif des modules d’accompagnement et d’apprentissage'},
    201 => {hname: 'Durée réelle des modules'},
    # ---------------------------------------------------------------------

    # ---------------------------------------------------------------------
    'travail'       => {hname: 'Travail au sein de l’atelier', titre: true},
    11  => {hname: 'Constitution du bureau de travail'},
    410 => {hname: 'Échéance du travail'},

    # ---------------------------------------------------------------------
    'documents'     => {hname: 'Les documents de travail', titre: true},
    31  => {hname: 'Code couleur pour les commentaires'},
    37  => {hname: 'Abréviations dans les commentaires'},
    32  => {hname: 'Nommage de ses documents de travail'},
    33  => {hname: 'Rédaction des documents de travail'},
    35  => {hname: 'Ajout de documents'},
    30  => {hname: 'Pourquoi partager ses documents ?'},
    36  => {hname: 'Comment recharger ses commentaires ?'},
    10  => { hname: 'Auto-estimation de ses documents'},
    34  => {hname: 'Types de documents'},
    # ---------------------------------------------------------------------

    # ---------------------------------------------------------------------
    'quaidesdocs'   => {hname: 'le Quai des docs', titre: true},
    600 => {hname: 'Qu’est-ce que le Quai des docs ?'},
    605 => {hname: 'Cotage des documents'},
    # ---------------------------------------------------------------------


    # ---------------------------------------------------------------------
    'divers'  => {hname: 'Divers', titre: true},
    701 => {hname: 'Grand Livre des Lois de la Narration'},
    700 => {hname: 'Inscription visiteur pour le frigo'},
    80  => {hname: 'Paiement du module ou de l’échéance'},
    81  => {hname: 'Conditions Générales d’Utilisation'}
  }

end #/Aide
