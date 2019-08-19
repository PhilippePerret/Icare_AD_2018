# encoding: UTF-8
class Integer
  DUREE_MINUTE  = 60
  DUREE_HEURE   = 60 * DUREE_MINUTE
  DUREE_JOUR    = 24 * DUREE_HEURE

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

  end

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # Retourne le nombre de secondes (self) comme une duration respectant
  # la norme ISO 8601
  def as_iso_8601
    htime = self.decompose_as_time
    iso = "P"
    htime[:days]    && iso += "#{htime[:days]}D"
    iso += "T"
    htime[:hours]   && iso += "#{htime[:hours]}H"
    htime[:minutes] && iso += "#{htime[:minutes]}M"
    htime[:seconds] && iso += "#{htime[:seconds]}S"
    return iso
  end

  # Retourne le Integer qui est un nombre de secondes sous
  # forme d'un Hash contenant :
  #   :seconds      Les secondes
  #   :minutes      Les minutes
  #   :hours        Les heures
  #   :days         Les jours
  def decompose_as_time
    s = self
    days  = (s / 1.day).nil_if_zero
    reste = s % 1.day
    hours = (reste / 3600).nil_if_zero
    reste = reste % 3600
    minutes = (reste / 60).nil_if_zero
    seconds = (reste % 60).nil_if_zero
    {days: days, hours: hours, minutes: minutes, seconds: seconds}
  end

  def nil_if_zero
    if self == 0
      nil
    else
      self
    end
  end

  # Par exemple, lorsqu'un argument de fonction peut être
  # un array ou un string, cette méthode permet de ne pas
  # avoir à tester si l'élément est un array ou non.
  def in_array
    [self]
  end

  # Pour ne pas avoir à toujours passer des nombres
  # en string avant de les aligner
  def rjust( len, remp = " ") ; self.to_s.rjust(len, remp) end
  def ljust( len, remp = " ") ; self.to_s.ljust(len, remp) end

  # Pour compatiblité avec autres objets
  def to_i_inn
    self
  end

  # Pour compatibilité avec autres objets
  def nil_if_empty
    self
  end

  def in_hidden attrs = nil
    self.to_s.in_hidden attrs
  end

  def as_tarif
    self.to_f.as_tarif
  end

  # Retourne le nombre comme une durée en jours,
  # avec "jour(s) à la fin"
  def as_jours
    nombre_jours = self / DUREE_JOUR
    s = nombre_jours > 1 ? "s" : ""
    "#{nombre_jours} jour#{s}"
  end
  alias :as_jour :as_jours

  # Méthode qui retourne le temps en jours (et heures) s'il
  # fait plus d'un jour et en heures dans le cas contraire
  def as_jours_or_hours
    jrs = self / DUREE_JOUR
    hrs = (self % DUREE_JOUR) / 3600
    d = ""
    if jrs > 0
      d << "#{jrs} jour#{jrs > 1 ? 's' : ''}"
    end
    if hrs > 0
      d << " et " unless d.empty?
      d << "#{hrs} heure#{hrs > 1 ? 's' : ''}"
    end
    if d.empty?
      secs = (self % DUREE_JOUR) % 3600
      mns  = secs / 60
      scs  = secs % 60
      d << "#{mns} mns #{scs} secs"
    end
    d
  end
  alias :as_jour_or_hour :as_jours_or_hours

  # Retourne la date correspondant au fixnum (quand c'est un timestamp)
  def as_date format = :dd_mm_yyyy
    format_str =
    case format
    when :dd_mm_yyyy  then "%d %m %Y"
    when :dd_mm_yy    then "%d %m %y"
    when :mm_yyyy     then "%m %Y"
    when :mm_yy       then "%m %y"
    when :d_mois_yyyy then return as_human_date
    when :d_mois_court_yyyy then return as_human_date false
    else
      nil
    end
    unless format_str.nil?
      Time.at(self).strftime(format_str)
    end
  end
  MOIS_LONG = ['','janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août',
    'septembre', 'octobre', 'novembre', 'décembre']
  MOIS_COURT = ['','jan', 'fév', 'mars', 'avr', 'mai', 'juin', 'juil', 'août',
    'sept', 'oct', 'nov', 'déc']
  def as_human_date mois_long = true, with_clock = false, thin = nil, delim_hours = nil
    thin        ||= "<thin></thin>"
    delim_hours ||= "-"
    mois = mois_long ? MOIS_LONG[Time.at(self).month] : MOIS_COURT[Time.at(self).month]
    self_time = Time.at(self)
    ahd = self_time.strftime("%e") + thin + mois + thin + self_time.strftime("%Y")
    ahd << "#{thin}#{delim_hours}#{thin}" + self_time.strftime("%H:%M") if with_clock
    ahd.strip
  end

  def as_duree options = nil
    options ||= Hash.new
    options[:usec] ||= "\""
    options[:umin] ||= "'"
    options[:uhour] ||= "h"
    options[:ujour] = "jour" unless options.has_key?(:ujour)
    self.s2h(options)
  end

  def as_horloge
    self.s2h(usec: "", umin: ":", uhour: ":", hour_required: true)
  end

  # +options+
  #     :usec     L'unité pour les secondes
  #     :umin     L'unité pour les minutes
  #     :uhour    L'unité pour les heures
  #     :ujour    L'unité pour les jours (if any)
  #     :hour_required    Si true, les heures sont toujours affichées,
  #                       même si elle valent 0
  #     :no_days  Si true, on n'utilise pas le nombre de jours, on
  #               le convertit en heures.
  #               On peut le mettre implicitement à true en mettant
  #               :ujour à nil
  #     Par défaut, ce sera une horloge "h:mm:ss" avec toujours les
  #     heures.
  def s2h options = nil
    options ||= {
        usec: '', umin:':', uhour:':', ujour:'jrs',
        hour_required: true
      }
    options[:no_days] = true if options[:ujour].nil?

    mns = self / 60
    sec = (self % 60).to_s.rjust(2,'0')
    if mns > 60
      hrs = mns / 60
      mns = (mns % 60).to_s.rjust(2,'0')
      if hrs > 24
        nombre_jours = hrs / 24
        jrs = if options[:no_days]
          ""
        else
          "#{nombre_jours} #{options[:ujour]} "
        end
        hrs = hrs % 24 + ( options[:no_days] ? nombre_jours * 24 : 0)
      end
      hrs = "#{hrs}#{options[:uhour]}"
    else
      if options[:hour_required]
        hrs = "0#{options[:uhour]}"
        mns = mns.to_s.rjust(2, '0')
      else
        hrs = ""
      end
      jrs = ""
    end
    "#{jrs}#{hrs}#{mns}#{options[:umin]}#{sec}#{options[:usec]}"
  end

  def hours
    self * 3600
  end
  alias :hour :hours

  # @usage : <nombre>.day ou <nombre>.days
  # Retourne le nombre de secondes correspondantes
  def days
    self * DUREE_JOUR
  end
  alias :day :days

  def weeks
    self * 7 * DUREE_JOUR
  end
  alias :week :weeks

  def months
    (30.5 * self * DUREE_JOUR).to_i
  end
  alias :month :months

  def years
    self * DUREE_JOUR * 365
  end
  alias :year :years

  ##
  # Retourne le timestamp sous forme de date pour l'enregistrement
  # dans le calendrier en date inversée
  # Par exemple, l'heure 8 09 2015 - 10:15 retournera 20150908
  # Noter que c'est un Integer qui est retourné, pas un String
  def as_cal_date
    Time.at(self).strftime('%Y%m%d').to_i
  end

end
