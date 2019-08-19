# encoding: UTF-8
class SuperFile
  class << self

    # {String} The source root of the SuperFile gem. Useful when
    # requiring files that are relative to the root of the project.
    #
    def root
      @root ||= File.expand_path('../../../', __FILE__)
    end
    # module_function :root

  end # << self
end # SuperFile

