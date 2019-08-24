# encoding: UTF-8
class Signup
class << self
  def current_page_subtitle
    "#{data_state[:hname]} #{" (#{data_state[:numero]}/4)".in_span(class:'small')}"
  end

end #/<< self
end #/Signup
