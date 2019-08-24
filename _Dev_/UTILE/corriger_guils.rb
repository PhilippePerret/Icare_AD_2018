# encoding: UTF-8
=begin

  Script pour corriger tous les guillemets dans les bases de données

=end
require_relative 'db_utils'
SIMULATION = true
ON_OR_OFF = :offline # pour les données client
# ON_OR_OFF = :online # pour les données client

class ModTable
  attr_reader :table, :properties
  def initialize table, properties
    @table      = table
    @properties = properties
  end

  def traite
    puts "\n\n\n === TRAITEMENT DE TABLE #{table} ===\n"
    request = "SELECT id, #{properties.join(', ')} FROM #{table}"
    DB.force_execute(request).each do |dmod|
      print "--- Vérification DATA ##{dmod[:id].to_s.ljust(6)}    "
      @new_textes = {}
      properties.each do |prop|
        dmod[prop] || next
        if dmod[prop].match('«')
          @new_textes.merge!(prop => corrige_texte(dmod[prop]) )
        end
      end
      if @new_textes.empty?
        puts "OK"
      else
        puts "CORRECTION REQUISE"
        values  = []
        columns = []
        properties.each do |prop|
          if @new_textes[prop]
            values << @new_textes[prop]
            columns << "#{prop} = ?"
          end
        end
        values << dmod[:id]
        request = "UPDATE #{table} SET #{columns.join(', ')} WHERE id = ?"
        DB.execute(request, values)
      end
    end
  end

  def corrige_texte str
    # puts "---- ANCIEN: #{str}"
    str = str.gsub(/«[  ]/,'“').gsub(/[  ]»/,'”')
    # puts "\n\n---- NOUVEAU: #{str}"
    return str
  end

end

# ---------------------------------------------------------------------
# VÉRIFICATION DES MODULES D'APPRENTISSAGE

table       = 'icare_modules.absmodules'
properties  = [:short_description, :long_description]
tableModules = ModTable.new(table, properties)
tableModules.traite

# ---------------------------------------------------------------------
# VÉRIFICATION DES ÉTAPES

table       = 'icare_modules.absetapes'
properties  = [:titre, :objectif, :travail, :methode]
tableModules = ModTable.new(table, properties)
tableModules.traite
