# encoding: UTF-8
class SiteHtml
class TestSuite

  def verbose?  ; class_options[:verbose]       end
  def quiet?    ; class_options[:quiet]         end
  def debug?    ; class_options[:debug] == true end
  def online?   ; options[:online] == true            end
  def offline?  ; options[:offline] == true           end

  def class_options
    self.class::options || {}
  end

end #/TestSuite
end #/SiteHtml
