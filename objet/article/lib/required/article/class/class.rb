# encoding: UTF-8
class Article

  extend MethodesMainObjet

  class << self

    def titre ; @titre ||= 'Le Blog de la Boite' end

    def data_onglets
      @data_onglets ||= {
        "Article courant" => "article/#{current_article_id}/show",
        "Liste articles"  => 'article/list'
      }
    end

    # {Article} L'instance du dernier Article
    def last
      @last ||= new(current_article_id)
    end

    def current_article_id
      @current_article_id ||= begin
        require './objet/article/current.rb'
        CURRENT_ARTICLE_ID
      end
    end

    # Dossier contenant les textes des articles
    def folder_textes
      @folder_textes ||= folder_lib + 'texte'
    end

  end #/<< self
end #/Article
