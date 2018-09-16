# encoding: UTF-8

# require 'fileutils'
# require 'superfile/class'
# require 'superfile/errors'
# require 'superfile/instance'
# module SuperFile
#   extend self
# end

['class', 'errors', 'instance'].each do |subfolder|
  if RUBY_VERSION.to_i >= 2
    require_relative "superfile/#{subfolder}"
  else
    this_folder = File.dirname __FILE__
    require File.join(this_folder, 'superfile', subfolder)
  end
end
