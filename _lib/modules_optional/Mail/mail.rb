# encoding: UTF-8

require 'cgi'
require 'net/smtp'

class SiteHtml

  # Envoi d'un mail
  # @usage
  #   site.send_mail({
  #     to:     <mail receveur>,
  #     from:   <mail expéditeur>,
  #     subject:  "<le sujet>",
  #     message:  "<le message>"
  #   })
  # Paramètres supplémentaires :
  #     :formated         Si true, le message n'est pas traité
  #     :force_offline    Si true, le mail est envoyé même en OFFLINE
  #     :no_header_subject  Si true, on ne rajoute pas dans le sujet le
  #                         préfixe du site.
  #     :signature        Si FALSE, la signature n'est pas apposée.
  #                       True par défaut
  #     :data             Hash de données à utiliser pour le message
  #     :no_citation      Si true, n'ajoute pas la citation au mail
  #
  # RETURN True si tout s'est bien passé et l'instance
  # de l'erreur dans le cas contraire.
  #
  def exec_send_mail data_mail
    Mail.new(data_mail).send
  rescue Exception => e
    error e.message
    return e
  else
    true # pour confirmer que l'envoi a pu se faire
  end


end # /SiteHtml

# Pour le moment, on met ce module ici, mais il devra être
# mis dans un fichier si on a besoin de le charger ailleurs.
# Sur l'atelier il était dans un fichier séparé car le CRON-JOB
# en avait besoin
module MailModuleMethods
  # Initialize a new mail
  #
  # * PARAMS
  #   Cf. plus haut
  #
  def initialize data = nil
    @data = data
    data.each do |k,v|
      v = case v
      when FalseClass, TrueClass, Integer then v
      else
        v = v.strip if v.respond_to?(:strip)
        v == "" ? nil : v
      end
      instance_variable_set("@#{k}", v)
    end unless data.nil?
  end

  # ---------------------------------------------------------------------
  #   Méthode de définition et de récupération des variables volatiles
  #   de classe. Permet de définir des variables qui n'ont pas besoin
  #   d'être recalculées pour chaque mail
  # ---------------------------------------------------------------------
  def set_class key, value
    self.class.instance_variable_set("@#{key}", value)
  end
  def get_class key
    self.class.instance_variable_get("@#{key}")
  end


  # ---------------------------------------------------------------------
  # Le message complet final
  # ------------------------
  def fmessage
    "From: <#{from}>\nTo: <#{to}>\nMIME-Version: 1.0\nContent-type: text/html; charset=UTF-8\nSubject: #{fsubject}\n\n#{code_html}"
  end

  # ----------------------------------------------------------------------
  #   Sous-méthode de construction du message

  def from; @from ||= site.mail end
  def to  ; @to   ||= site.mail end

  def bind ; binding() end

  def code_html
    @code_html ||= <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html><head>#{content_type}#{title}</head><body style="background-color:#578088;max-width:680px;">#{ERB.new(body_responsive).result(bind)}</body></html>
    HTML
  end

  # / Sous-méthode de construction du message
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------
  #   Sous-sous-méthodes de construction du message

  # Pour la balise title du message HTML
  def title
    @title ||= "<title>#{subject}</title>"
  end

  # Le sujet tel qu'envoyé dans les données (non formaté)
  def subject
    @subject
  end

  def full_subject
    @full_subject ||= begin
      suj = subject || "(sans sujet)"
      @no_header_subject.nil? ? "#{header_subject}#{suj}" : suj
    end
  end

  # Le sujet codé en unicode, pour n'avoir aucun caractère spécial gênant
  def fsubject
    @fsubject ||= begin
      full_subject.gsub(SiteHtml::Mail.specialCharsInSubject, SiteHtml::Mail.regSubjectReplacement)
    end
  end

  def content_type
    if get_class(:content_type).nil?
      set_class(:content_type, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>')
    end
    get_class(:content_type)
  end

  # Le corps de mail pour un email responsive
  def body_responsive
    <<-HTML
<table style="max-width:600px;width:100%;background-color:white;">
  <colgroup>
    <col width="25%" style="min-width:25%;width:25%;">
    <col width="auto">
    <col width="auto">
  </colgroup>
  <%= header %>
  <tr><td colspan="3" style="<%= style_brut_message %>"><%=
    # Le contenu du mail
    message_formated
  %></td></tr>
  <tr><td colspan="2">&nbsp;</td>
    <td style="max-width:50%;"><%=
      # La signature
      signature
  %></td></tr>
  <%= footer %>
</table>
    HTML
  end

  def style_brut_message
    'font-size:1rem;padding:1rem;'
  end

  # / Sous-sous-méthodes
  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #   Sous-sous-sous méthodes de construction du message

  def header
    @data[:no_header] && (return '')
    if get_class(:header).nil?
      set_class(:header, SiteHtml::Mail.respond_to?(:header) ? SiteHtml::Mail.header : "" )
    end
    get_class :header
  end

  def header_subject
    if get_class(:header_subject).nil?
      set_class(:header_subject, site.mail_before_subject ? site.mail_before_subject : "" )
    end
    get_class :header_subject
  end

  def signature
    return '' if @signature === false # in data
    get_class(:signature) || ''
  end

  def footer
    @data[:no_footer] && (return '')
    set_class(:footer, SiteHtml::Mail.respond_to?(:footer) ? SiteHtml::Mail.footer : "") if get_class(:footer).nil?
    get_class :footer
  end


  # ---------------------------------------------------------------------
  #   Sous-sous-sous-sous méthodes de construction du message

  def message_formated
    return @message if already_formarted?
    c = @message
    if return_to_br_in_message?
      if c.match("\n")
        c.gsub!(/\n/, '<br>')
        c.gsub!(/\r/, '')
      elsif c.match("\r")
        c.gsub!(/\r/, '<br>')
        c.gsub!(/\n/, '')
      end
    end
    "<div>#{c}</div>"
  end


  # ---------------------------------------------------------------------
  #   Méthode d'état ou fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne true si le message est formaté HTML
  def already_formarted?
    @formated == true || @message.match(/(<div |<p )/)
  end

  # Return true s'il faut corriger les retours de chariot et
  # les remplacer par des <br>
  # Note : Seulement si le message doit être formaté
  def return_to_br_in_message?
    if defined? CORRECT_RETURN_IN_MESSAGE
      CORRECT_RETURN_IN_MESSAGE
    else
      true
    end
  end
end # /fin module MailModuleMethods

#
# ---------------------------------------------------------------------
#
#   L'INSTANCE MAIL
#

class SiteHtml
  class Mail

    include MailModuleMethods

    # Les données SMTP pour l'envoi des mails
    require File.join('.', 'data', 'secret', 'data_mail.rb')

    # -------------------------------------------------------------------
    #   Classe
    # -------------------------------------------------------------------

    class << self

      # Send the mail (don't call directly, use Mail.new(...) instead)
      #
      # * PARAMS
      #   :mail::       Formated mail code
      #   :to::         Email address of the receiver
      #   :from::       Email address of the sender (me by default)
      #
      def send mail, to, from
        Net::SMTP.start(
          MY_SMTP[:server],
          MY_SMTP[:port],
          'localhost',      # serveur From (sera à régler plus tard suivant
                            # online/offline)
          MY_SMTP[:user],
          MY_SMTP[:password]
          ) do |smtp|
            smtp.send_message mail, from, to
        end
      end

      def online?
        @is_online ||= begin
          if defined?(ONLINE)
            ONLINE
          else
            (ENV['HTTP_HOST'] != nil && ENV['HTTP_HOST'] != 'localhost' && ENV['HTTP_HOST'] != '127.0.0.1')
          end
        end
      end
      def offline?
        @is_offline ||= !online?
      end

    end # /<< self

    # -------------------------------------------------------------------
    #   Instance
    # -------------------------------------------------------------------

    # Données transmises à l'instanciation
    attr_reader :data

    # Mail format (:html, :text, :both)
    attr_reader :format

    # Envoi du message
    # ----------------
    # Quelle que soit la situation, on enregistre un fichier Marshal
    # du mail envoyé.
    # On n'envoie le mail que si on est en online ou si on
    # doit forcer l'envoyer même en offline.
    def send
      if self.class.respond_to?(:send_offline)
        now = Time.now.to_i
        self.class.send_offline data.merge(
            fsubject:       fsubject,          # Le sujet formaté
            full_subject:   full_subject, # Le sujet avec l'entête éventuelle (p.e. '[ICARE] ')
            subject:        subject,      # Le sujet tel que transmis
            to:             to,
            from:           from,
            message:        @message,      # Le message tel que transmis à la méthode
            fmessage:       fmessage,    # Le message formaté
            sent_at:        now
          )
      end
      if self.class.online? || @force_offline
        self.class.send( fmessage, to, from)
      end
    end

    # ---------------------------------------------------------------------
    #   POUR CORRIGER LE SUJET

    # Cf. http://www.fileformat.info/info/unicode/char/00f4/index.htm
    #     http://www.fileformat.info/info/unicode/category/Po/list.htm
    REAL_LETTER_TO_SUBJECT_CODE = {
      'ç' => 'A7', # -> =C3=A7
      'Ç' => '87',
      'é' => 'A9',
      'É' => '89',
      'è' => 'A8',
      'ê' => 'AA',
      'ë' => 'AB',
      'Ê' => '8A',
      'à' => 'A0',
      'â' => 'A2',
      'æ' => 'A6',
      'Â' => '82',
      'Ô' => '94',
      'ô' => 'F4',
      'ö' => 'B6',
      'Œ' => ['C5','92'],
      'œ' => ['C5','93'],
      'ù' => 'B9',
      'û' => 'BB',
      'ü' => 'BC',
      'Ù' => '99',
      'Û' => '9B',
      'î' => 'AE',
      'ï' => 'AF',
      '…' => ['E2','80','A6'],
    }
    def self.regSubjectReplacement
      @regSubjectReplacement ||= begin
        hrep = {}
        REAL_LETTER_TO_SUBJECT_CODE.each do |letter, co|
          hrep.merge!(letter => co.is_a?(String) ? "=C3=#{co}" : co.collect{|oc|"=#{oc}"}.join(''))
        end
        hrep
      end
    end
    def self.specialCharsInSubject
      @specialCharsInSubject ||= /[#{REAL_LETTER_TO_SUBJECT_CODE.keys.join('')}]/
    end

  end #/Mail
end #/SiteHtml
