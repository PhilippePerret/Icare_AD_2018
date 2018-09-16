# encoding: UTF-8
=begin

Si un dossier ./objet/user/lib/required existe, on le charge toujours

=end
class User
  class << self

    def init
      folder_custom_required.require if folder_custom_required.exist?
    end

    def folder_custom_required; @fldcustreq ||= folder_custom_lib+'required' end
    def folder_custom_lib     ; @fldcustlib ||= site.folder_objet+'user/lib' end
  end#/<< self
end#/User
