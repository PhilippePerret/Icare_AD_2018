# encoding: UTF-8
class Admin
class Mailing

class << self

  # RETURN la liste des instances des icariens à qui il faut envoyer
  # le message.
  def destinataires
    @destinataires ||= begin
      outs = site.mails_out || Array.new
      table = force_offline? ? site.dbm_table(:users, 'users', online = true) : dbtable_users
      table.select(where: clause_where, colonnes: [:mail]).collect do |huser|
        outs.include?(huser[:mail]) && next
        User.new(huser[:id])
      end.compact
    end
  end

  def clause_where
    # Clause WHERE en fonction des clés
    # Défini par le 17e bit (bit 16) des options
    # et le 25e bit (bit 24) pour la réalité
    clause16    = Array.new
    clause24    = Array.new
    clauseAdmin = Array.new
    KEYS_DESTINATAIRES.each do |ictype, dtype|
      if dtype[:checked]
        bit1, bit16, bit24 =
          case ictype
          when :all       then  [nil, nil, nil]
          when :actif     then  [nil, 2, 1]
          when :ancien    then  [nil, 4, 1]
          when :enpause   then  [nil, 3, 1]
          when :alessai   then  [nil, nil, 0]
          when :real      then  [nil, nil, 1]
          when :admin     then  [true, nil, nil]
          end
      end
      if bit1
        clauseAdmin << "CONVERT(SUBSTRING(options,1,1),INTEGER) > 0"
      end
      if bit16
        clause16 << "SUBSTRING(options,17,1) = '#{bit16}'"
      end
      if bit24
        clause24 << "SUBSTRING(options,25,1) = '#{bit24}'"
      end
    end
    clauses = Array.new
    clauses << "( SUBSTRING(options,18,1) = '0' ) " # aucun mail, ever
    return nil if clause16.empty? && clause24.empty? && clauseAdmin.empty?
    clause16.empty?     || clauses << "( #{clause16.join(' OR ')} )"
    clause24.empty?     || clauses << "( #{clause24.join(' OR ')} )"
    clauseAdmin.empty?  || clauses << "( #{clauseAdmin.join(' OR ')} )"
    clauses = clauses.join(' AND ')
    debug "Clause where pour icariens : #{clauses}"
    return clauses
  end

end #<< self
end #/ Mailing
end #/ Admin
