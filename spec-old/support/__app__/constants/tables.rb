# encoding: UTF-8

def table_users
  @table_users ||= site.dbm_table(:users, 'users')
end
def table_watchers
  @table_watchers ||= site.dbm_table(:hot, 'watchers')
end
def table_paiements
  @table_paiements ||= site.dbm_table(:users, 'paiements')
end
def table_actualites
  @table_actualites ||= site.dbm_table(:hot, 'actualites')
end


def table_icmodules
  @table_icmodules ||= site.dbm_table(:modules, 'icmodules')
end
def table_icetapes
  @table_icetapes ||= site.dbm_table(:modules, 'icetapes')
end
def table_icdocuments
  @table_icdocuments ||= site.dbm_table(:modules, 'icdocuments')
end
def table_absmodules
  @table_abs_modules ||= site.dbm_table(:modules, 'absmodules')
end
def table_absetapes
  @table_absetapes ||= site.dbm_table(:modules, 'absetapes')
end
