#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  IL FAUT LANCER CE SCRIPT DANS TEXTMATE POUR ACTUALISER LES SASS -> CSS
  OU DANS ATOM AVEC CMD I
  SI ON LE LANCE DEPUIS UN SITE, IL FAUT SUPPRIMER LA LIGNE "puts" CI-DESSOUS
=end
require 'sass'
Dir["./**/*.sass"].each do |src_path|
  folder = File.dirname( src_path )
  css_path = File.join(folder, File.basename(src_path, File.extname(src_path)) + '.css')
  if false == File.exist?(css_path) || File.stat(css_path).mtime < File.stat(src_path).mtime
    # puts "#{src_path} -> #{css_path}"
    data_compilation = { line_comments: false, style: :compressed }
    Sass.compile_file( src_path, css_path, data_compilation )
  end
end
