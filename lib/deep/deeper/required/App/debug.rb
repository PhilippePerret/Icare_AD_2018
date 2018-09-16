# encoding: UTF-8
class App

  # Pour pouvoir utiliser app.debug (rappel : App est un singleton)
  #
  # +arg+ est ajouté pour pouvoir utiliser la méthode général `debug'
  # dans cette classe aussi.
  def debug arg = nil
    @debug ||= Debug.new
    arg.nil? || @debug.add(arg)
    @debug
  end

  # ---------------------------------------------------------------------
  #   App::Debug
  # ---------------------------------------------------------------------
  class Debug
    def initialize
      @messages = Array.new
    end
    def add mess
      case mess
      when String
        # rien à faire
        message_simple = mess
      else
        if mess.respond_to?(:message)
          message_simple = mess.message
          mess = message_simple + "\n\n" + mess.backtrace.join("\n")
        else
          mess = mess.to_s
        end
      end
      mess += "\n"

      app.benchmark("DEBUG: #{message_simple}")

      # mess = mess.class.to_s
      @messages << mess
      write mess
      # raise "J’ÉCRIS LE MESSAGE #{mess}"
    end
    def output
      return "" if @messages.empty?
      @messages.join('')
    end
    def write mess
      reffile.write "-- #{mess}"
    end
    def reffile
      @reffile ||= init_reffile
    end
    def init_reffile
      rf = File.open(file_path,'a')
      rf.write "\n\n=== DEBUG DU #{Time.now.strftime('%d %m %Y - %H:%M:%S')} ===\n\n"
      return rf
    end
    def file_path
      @file_path ||= File.join('.','debug.log')
    end
  end
end
