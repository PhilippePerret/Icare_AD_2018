# encoding: UTF-8
class Article
class << self

  def list_as_ul
    Dir["#{folder_textes}/*"].collect do |p|
      id = File.basename(p).to_i
      new(id).titre.in_a(href: "article/#{id}/show").in_li
    end.join('').in_ul
  end

end #<< self
end #/Article
