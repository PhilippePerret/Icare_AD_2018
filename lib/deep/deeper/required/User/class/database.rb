# encoding: UTF-8
=begin
Tout ce qui concerne les bases de données pour User
=end
class User
  class << self

    def table
      @table_users ||= site.dbm_table(:users, 'users')
    end
    alias :table_users :table

    def table_paiements
      @table_paiements ||= site.dbm_table(:users, 'paiements')
    end

  end#/<< self
end#/<< User
