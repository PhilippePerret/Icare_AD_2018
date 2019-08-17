# encoding: UTF-8
=begin

Pour le traitement d'un fichier (après avoir récolté ses informations)

=end
class SFile

  ##
  ## Path du fichier
  ##
  attr_reader :path

  ##
  ## Hash de toutes ses données (sauf le path)
  ##
  attr_reader :data

  def initialize fpath, fdata
    @path = fpath
    @data = fdata
  end

  ##
  #
  # = main =
  #
  # Méthode principale de traitement du fichier
  #
  #
  def traite
    row_file
  end

  # ---------------------------------------------------------------------
  #
  #   Méthodes de construction
  #
  #

  ##
  #
  # Retourne le code HTML pour la rangée du fichier de données +fdata+
  #
  def row
    @row ||= begin
      colonnes = ""
      colonnes << colonne_serveur
      colonnes << colonne_local
      colonnes << colonne_file_name
      "<div class='row #{row_type}'>" + colonnes + "</div>"
    end
  end


  ##
  #
  # @return le code HTML pour le div de colonne du nom de fichier
  #
  def colonne_file_name
    "<div class='col fname'>#{path}</div>"
  end

  ##
  #
  # @return le code HTML pour le div de la donnée serveur
  #
  def colonne_serveur
    d = if distant_time.nil?
      "#{bouton_upload}INEXISTANT"
    else
      ( time_ok? ? "" : bouton_upload ) +
      ( local_time.nil? ? bouton_destroy : "") +
      Time.at(distant_time).strftime("%d %m %Y - %H:%M")
    end
    "<div class='col distant'>#{d}</div>"
  end

  ##
  #
  # RETURN le code HTML pour le div de la donnée locale
  #
  def colonne_local
    d = if local_time.nil?
      "#{bouton_download}INEXISTANT"
    else
      ( distant_time.nil? ? bouton_destroy : "") +
      Time.at(local_time).strftime("%d %m %Y - %H:%M")
    end
    "<div class='col local'>#{d}</div>"
  end

  # ---------------------------------------------------------------------
  # Les méthodes de construction des boutons
  #
  def bouton_download
    bouton 'download'
  end
  def bouton_upload
    bouton "upload"
  end
  def bouton_destroy
    bouton "destroy"
  end
  def bouton method
    "<a href='javascript:void(0)' class='#{method}' data-path='#{path}'>#{method}</a>"
  end

  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #

  ##
  #
  # Renvoie la class pour la rangée en fonction du fait
  # que le fichier est synchronisé (ok) ou pas (err)
  #
  def row_type
    @row_type ||= (time_ok? ? 'ok' : 'err')
  end

  ##
  #
  # RETURN TRUE si les temps de synchro sont bons
  #
  def time_ok?
    @time_is_ok ||= check_time
  end

  def check_time
    return false  if local_time.nil? || distant_time.nil?
    return true   if local_time == distant_time
    return true   if direction == :s2l && local_time > distant_time
    return true   if direction == :l2s && distant_time > local_time
    return false
  end

  def local_time
    @local_time ||= data[:tloc]
  end
  def distant_time
    @distant_time ||= data[:tdis]
  end

  ##
  #
  # La "direction" correspond à l'endroit où le fichier doit être
  # le plus jeune.
  #   Si…       Alors…
  #   :l2s      Le fichier sur serveur doit être égal ou plus jeune
  #   :s2l      Le fichier local doit être égal ou plus jeune
  #   :both     Les deux fichiers doivent avoir le même âge
  #
  def direction
    @direction ||= data[:dir]
  end

end
