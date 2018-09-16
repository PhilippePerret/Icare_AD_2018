# encoding: UTF-8
=begin
  Méthodes pour le formatage du commentaire
=end
class Page
  class Comments

    # = main =
    #
    # Prend le commentaire original et le formate
    #
    def formate_comment
      c = comment.dup
      c = c.strip
      # On supprime les textes entre balises et les balises elles-mêmes
      c = c.gsub(/<(.*)(?: (?:.*?))?>(.*?)<\/\1>/m, '').strip
      # On supprimer les balises seules
      c = c.gsub(/<(.*?)>/m,'').strip

      ['u', 'i', 'b', 'strike'].each do |tag|
        c.gsub!(/\[#{tag}\](.*?)\[\/#{tag}\]/){
          "<#{tag}>#{$1}</#{tag}>"
        }
      end

      # Les balises solitaires
      c = c.gsub(/\[(hr|br)\]/, '<\1>')

      # Les liens internet
      c = c.gsub(/\[url(?:=(?:'|")(.*?)(?:'|"))?\](.*?)\[\/url\]/){
        url   = $1 || $2
        titre = $2 || url
        url.start_with?('http://') || url = "http://#{url}"
        "<a href=\"#{url}\">#{titre}</a>"
      }

      # À la fin, on découpe en paragraphe
      if c.match(/\n/)
        c = c.gsub(/\r/, '')
      else
        c = c.gsub(/\r/, "\n")
      end

      c = c.split("\n\n").collect do |par|
        par.strip.in_p
      end.join('')

      c = c.nil_if_empty
      c != nil || raise('Votre commentaire est incorrect…')

      @comment = c
    end

  end #/Comments
end #/Page
