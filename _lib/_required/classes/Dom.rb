# encoding: UTF-8

class Dom
class << self

  def image relpath, attrs
    attrs = attrs.collect{|attr,val|"#{attr}=\"#{val}\""}.join(' ')
    "<img src=\"#{folder_images}/#{relpath}\" #{attrs} />"
  end
  alias :img :image

  def folder_images
    @folder_images ||= '_view/img'
  end

end #/<< self
end #/Dom
