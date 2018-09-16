# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def code_connexion_mysql_online
    require './data/secret/mysql'
    dms = DATA_MYSQL[:online]
    code = "mysql -h #{dms[:host]} -u #{dms[:username]} -p#{dms[:password]}"
    sub_log code.in_input_text(onfocus: 'this.select()', style: 'width:800px;')
    return ''
  end

  def code_connexion_mysql_offline
    require './data/secret/mysql'
    dms = DATA_MYSQL[:offline]
    code = "mysql -h #{dms[:host]} -u #{dms[:username]} -p#{dms[:password]}"
    sub_log code.in_input_text(onfocus: 'this.select()', style: 'width:800px;')
    return ''
  end

end #/Console
end #/Admin
end #/SiteHtml
