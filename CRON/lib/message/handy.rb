# encoding: UTF-8


def log str, options = nil
  Cron::Message.log str, options
end

# Pour débugger un message d'erreur ou un message string
# Noter que cette méthode surclasse la méthode générale du
# site.
def debug err
  err =
    case err
    when String
      err
    else
      if err.respond_to?(:backtrace)
        err.message + "\n" + err.backtrace.join("\n")
      else
        err.inspect
      end
    end
  debug_file.write "\n\n--- #{Time.now} ---\n#{err}"
rescue Exception => e
  # Ne rien faire pour le moment
end
def debug_file
  @debug_file ||= begin
    File.open("#{APP_FOLDER}/CRON/debug_file.txt",'a')
  end
end
