# encoding: UTF-8
class Admin
class Users
class << self

  def exec_code_sur_table

    code_final = <<-CODE
dbtable_users.select.each do |huser|
  uid = huser[:id]
  u   = User.new(uid)
  #{long_value}
end
    CODE
    debug "Code : #{long_value}"

    success = nil
    begin
      eval(code_final)
      success = true
    rescue Exception => e
      debug e
      success = false
    end

    flash( success ? 'Code exécuté avec succès.' : 'Un problème est survenu (voir le debug)')
  end

end #/<< self
end #/Users
end #/Admin
