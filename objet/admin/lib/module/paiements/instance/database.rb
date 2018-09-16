# encoding: UTF-8
class Admin
class Paiements

  def get_paiements from, to
    where = "created_at >= #{from} AND created_at < #{to}"
    table.select(where: where, order: 'created_at ASC')
  end

  def table
    @table ||= User.table_paiements
  end

end #/Paiements
end #/Admin
