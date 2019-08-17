# encoding: UTF-8
class App

  def test?
    @is_mode_test = path_mode_test_file.exist?
  end

  def set_mode_test on_off = true
    if on_off
      path_mode_test_file.write Time.now.to_i.to_s
    else
      path_mode_test_file.remove if path_mode_test_file.exist?
    end
    @is_mode_test = nil
  end

  def path_mode_test_file
    @path_mode_test_file ||= SuperFile.new(['.', '.TEST_ON'])
  end
end
