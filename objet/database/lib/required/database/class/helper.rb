# encoding: UTF-8
class Database
class << self

  # Liste HTML des bases de données
  def as_select
    list.collect{|dbn| [dbn, dbn]}.
      in_select(
        id: 'database', name: 'database[name]',
        size: 10, onchange: "$.proxy(Database,'onchoose_base')()"
        )
  end

end #/<< self
end #/Database
