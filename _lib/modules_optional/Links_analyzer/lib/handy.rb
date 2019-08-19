# encoding: UTF-8

# if VERBOSE
#   alias :top_puts :puts
#   def puts foo
#     top_puts foo
#   end
# else
#   def puts foo
#     @lesputs ||= Array.new
#     @lesputs << foo
#   end
# end

def say mess
  puts mess
end

# Pour réceptionner le débug
# Pour le moment, on n'en fait rien
def debug err
  message, backtrace =
    case err.respond_to?(:message)
    when true
      [err.message, err.backtrace.join("\n")]
    else
      [err, nil]
    end
  puts "\n\n### ERREUR ###"
  puts message
  puts backtrace if backtrace
  puts "### /ERREUR ###\n\n"
end
