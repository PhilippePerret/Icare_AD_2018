# encoding: UTF-8
class App

  def div_flash
    flash_content = (error.output + notice.output)
    return "" if flash_content == ""
    flash_content.in_div(id: "flash")
  end

  def flash_sessionnalize
    notice.sessionnalize
    error.sessionnalize
  end

  def flash_dessessionnalize
    notice.dessessionnalize
    error.dessessionnalize
  end

  def errors_as_list errs, options = nil
    error.add("<ul>#{errs.collect{|err|"<li>#{err}</li>"}.join('')}</ul>", options)
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
      return if @messages.include?(mess) # pas le même message deux fois
      @messages << mess
    end
    def output
      return "" if messages.empty?
      @output ||= begin
        messages.collect{|m| m.in_div(class:'notice')}.join('').in_div(id:'notices')
      end
    end
    # Mise en session des messages s'il y en a
    def sessionnalize
      return if messages.empty?
      session['flash-notices'] = messages.join(';;;')
    end
    def dessessionnalize
      return if session['flash-notices'].nil?
      @messages = session['flash-notices'].split(';;;')
      session['flash-notices'] = nil
    end
    def session
      app.session
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

    def sessionnalize
      return if errors.empty?
      session['flash-errors'] = errors.collect do |err|
        case err
        when String then err
        else
          err.respond_to?(:message) ? err.message : err.inspect
        end
      end.join(';;;')
    end

    def dessessionnalize
      return if session['flash-errors'].nil?
      @errors = session['flash-errors'].split(';;;')
      session['flash-errors'] = nil
    end

    def session
      app.session
    end
  end
end
