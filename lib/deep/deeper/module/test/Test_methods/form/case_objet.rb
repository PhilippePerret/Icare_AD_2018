# encoding: UTF-8
class SiteHtml
class TestSuite
class TestForm < DSLTestMethod

  def curl_request data_req = nil
    data_req.nil? || @curl_request = nil
    @curl_request ||= req_curl = SiteHtml::TestSuite::Request::CURL.new(self, {form: true, data: data_req})
  end

end #/TestForm
end #/TestSuite
end #/SiteHtml
