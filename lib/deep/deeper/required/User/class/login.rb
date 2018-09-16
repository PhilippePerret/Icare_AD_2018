# encoding: UTF-8
require 'digest/md5'
class User
  class << self

    # Identification
    def login
      login_ok? || begin
        error "Je ne vous reconnais pas… Voulez-vous bien réessayer ?"
        redirect_to 'user/signin'
      end
    end

    # RETURN True si l'identification est réussie
    #
    def login_ok?
      login_data = param(:login)
      if login_data.nil?
        # Ça arrive quelquefois quand ça tourne trop longtemps
        # ou autre
        return false
      else
        umail = login_data[:mail]
        upass = login_data[:password]
        res = table_users.select(where: {mail: umail}, colonnes: [:salt, :cpassword, :mail]).first
        # debug "data user #{umail} dans table : #{res.inspect}"
        res != nil || (return false)
        expected = res[:cpassword]
        compared = Digest::MD5.hexdigest("#{upass}#{umail}#{res[:salt]}")
        # debug "expected: #{expected}"
        # debug "compared: #{compared}"
        ok = expected == compared
        ok && User.new( res[:id] ).login
        return ok
      end
    end

  end # << self
end
