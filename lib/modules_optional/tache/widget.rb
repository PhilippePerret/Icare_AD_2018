# encoding: UTF-8
=begin

Ce module permet d'insérer dans la page, lorsque l'on est administrateur,
un bouton permettant de générer automatiquement une tâche pour corriger,
relire, signaler un bug, etc.

=end
class ::Admin
class Taches

  # template: Le texte modèle qui servira à composer le texte
  # de la tâche.
  DATA_TACHES_TYPE = {
    warn:   {hname:"Signaler un bug", dest: :manitou,
      template:"BUG signalé sur la page %{page} : %{detail}",
      echeance: 0
    },
    rell:   {hname:"Marquer à relire (par lecteurs)", dest: :lecteurs,
      template:"La page %{page} est à relire",
      echeance: 7.day
    },
    mkok:   {hname: "PAGE OK (après vérification)", dest: 1,
      template: "Page %{page} marquée OK par #{user.pseudo} après vérification.",
      echeance: 3.days
    },

    corr:   {hname:"Marquer à corriger", dest: user.id,
      template:"La page %{page} est à corriger",
      echeance: 2.day
    },
    deep:   {hname:"Marquer à approfondir", dest: user.id,
      template:"La page %{page} est à approfondir",
      echeance: 2.day
    },
    relm:   {hname:"Marquer à relire (par moi)", dest: user.id,
      template:"La page %{page} est à relire",
      echeance: 7.day
    },
    typo:   {hname:"Signaler une erreur typographique", dest: :manitou,
      template:"ERREUR TYPOGRAPHIQUE signalée sur la page %{page} : %{detail}",
      echeance: 0
    },
    kill:   {hname:"Marquer à détruire", dest: user.id,
      template:"",
      echeance: 0
    }
  }

end #/Taches
end #/Admin
