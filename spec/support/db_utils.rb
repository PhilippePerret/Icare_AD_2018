# encoding: UTF-8
SIMULATION = false
ON_OR_OFF = :offline
require './_Dev_/UTILE/db_utils'

DATA_DATABASES = {
  'icare_cold'    => ['page_comments', 'taches', 'temoignages', 'updates'],
  'icare_hot'     => ['actualites','checkform', ['connexions', 'time'], ['connexions_per_ip','time'], 'taches', 'tickets', 'watchers'],
  'icare_modules' => ['abs_travaux_type', 'absetapes', 'absmodules', 'icdocuments', ['icetapes','started_at'], 'icmodules', 'lectures_qdd', 'mini_faq'],
  'icare_users'   => ['users', 'frigo_discussions', 'frigo_messages', 'frigos', 'paiements']
}

def db_erase_all_after time
  puts "\n\nEffacement des données DB créées après le test (#{time})…"

  time.is_a?(Integer) || time = time.to_i

  DATA_DATABASES.each do |db_name, tables|
    puts "*** DATABASE #{db_name}"
    tables.each do |tbl_name|
      if tbl_name.is_a?(Array)
        tbl_name, property = tbl_name
      else
        property = 'created_at'
      end
      print "* Table #{db_name}.#{tbl_name}…".ljust(44)
      count_init = DB.count("#{db_name}.#{tbl_name}")
      request = "DELETE FROM #{db_name}.#{tbl_name} WHERE #{property} > ?"
      res = DB.execute(request, [time])
      count_after = DB.count("#{db_name}.#{tbl_name}")
      if count_after < count_init
        puts " #{count_init - count_after} SUPPRESSION(S)"
      else
        puts " OK"
      end
    end
  end

end

def db_backup_all_databases
  print "*** Backup de toutes les bases icare…"
  DATA_DATABASES.each do |db_name, tables|
    `mysqldump -u root #{db_name} > /Users/philippeperret/Sites/xoffline/Backups_DB_Icare/#{db_name}.sql`
  end
  puts "   OK"
end
