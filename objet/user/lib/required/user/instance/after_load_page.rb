# encoding: UTF-8
class User



  # À faire après un chargement de page
  #
  def do_after_load
    app.benchmark('-> User#do_after_load')
    app.benchmark('<- User#do_after_load')
  end

  # Méthode utilisée pour envoyer une alerte à l'administrateur
  # suite à une nouvelle connexion.
  def send_admin_new_connexion
#     User::get(1).send_mail(
#       subject:  "Nouvelle connexion",
#       formated: true,
#       message: <<-MAIL
# <p>Phil, je t'informe d'une nouvelle identification :</p>
# <pre style="font-size:11pt">
#   Pseudo  : #{pseudo} (##{id})
#   Date    : #{Time.now.to_i.as_human_date(true, true, ' ')}
#   IP      : #{ip}
#   Session : #{app.session.session_id}
# </pre>
#       MAIL
#     )
  end

end
