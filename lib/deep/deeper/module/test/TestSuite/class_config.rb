# encoding: UTF-8
class SiteHtml
class TestSuite
class << self

  def configure &block
    current.folder_test_path= "none"

    instance_eval(&block) if block_given?

  end

end #/<< self
end #/TestSuite
end #/ SiteHtml
