# encoding: UTF-8
class TestedPage
  class Link

    # Index du lien dans la page
    attr_reader :index

    # Instance NokogiriXMLElement
    attr_reader :nokoxmlelement

    # Instanciation à partir du lien brut tel qu'écrit dans le
    # code de la page HTML
    def initialize nokoxmlelement, ilink
      @nokoxmlelement = nokoxmlelement
      @index          = ilink
    end

    # Le texte du lien
    def text
      @text ||= nokoxmlelement.inner_html
    end

    # L'attribut HREF du lien
    def href
      @href ||= begin
        h = nokoxmlelement.attr('href')
        h != '' ? h : 'site/home'
      end
    end

    # Retourne true si c'est un lien javascript (donc ne conduisant pas,
    # a priori, à une page)
    def javascript?
      @is_void = (href == 'javascript:void(0)') if @is_void === nil
      @is_void
    end

  end #/Link
end #/TestedPage
