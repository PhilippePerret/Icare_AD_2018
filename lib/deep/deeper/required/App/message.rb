# encoding: UTF-8
class App

  def div_flash
    flash_content = (error.output + notice.output)
    return "" if flash_content == ""
    flash_content.in_div(id: "flash")
  end

  def error
    @error ||= ErrorDealer.new
  end
  def notice
    @notice ||= MessageDealer.new
  end

  # ---------------------------------------------------------------------
  #   Class App::MessageDealer
  # ---------------------------------------------------------------------
  class MessageDealer
    attr_reader :messages
    def initialize
      @messages = Array.new
    end
    def add mess, options = nil
      @messages << mess
    end
    def output
      return "" if messages.empty?
      @output ||= begin
        messages.collect{|m| m.in_div(class:'notice')}.join('').in_div(id: 'messages')
      end
    end
  end
  # ---------------------------------------------------------------------
  #   Class App::ErrorDealer
  # ---------------------------------------------------------------------
  class ErrorDealer
    attr_reader :errors
    def initialize
      @errors = Array.new
    end
    def add err, options = nil
      @errors << err
      return false
    end
    def output
      return '' if errors.empty?
      @output ||= begin
        errors.collect do |e|
          m = case e
          when String then e
          else
            if e.respond_to?(:message)
              e.message
            else
              e.inspect
            end
          end
          m.in_div(class:'error')
        end.join('').in_div(id:'errors')
      end
    end
  end
end

def error err, options = nil
  app.error.add err, options
end
def flash mess, options = nil
  app.notice.add mess, options
end
