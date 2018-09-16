# encoding: UTF-8

class NotRunOnline < StandardError; end
class NotRunOffline < StandardError; end

class SiteHtml
class TestSuite
class TestFile

  def verbose?  ; @verbose  end
  def quiet?    ; @quiet    end

  def only_online
    SiteHtml::TestSuite.online? || raise( NotRunOnline )
  end
  def only_offline
    SiteHtml::TestSuite.offline? || raise( NotRunOffline )
  end

end #/TestFile
end #/TestSuite
end #/SiteHtml
