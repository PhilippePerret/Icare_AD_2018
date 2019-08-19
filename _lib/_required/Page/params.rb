# encoding: UTF-8
require 'uri'
class Page
  include Singleton

  # {Hash} Les paramètres déjà lus
  # Noter que les paramètres ne se trouvent dans cette
  # variables d'instance (page.custom_params) que si on
  # les a appelés au cours du programme (c'est le comportement
  # "lazzy" normal du programme).
  # Pour forcer la lecture des paramètres, utiliser la
  # méthode 'page.all_params'
  attr_reader :custom_params

  # Retourne le paramètre de demandé ou le définit
  def param param_name, value = nil, forcer = false
    decomplexe_values_cgi unless @cgi_values_decomplexed
    if (param_name.class == Hash) || (value != nil) || (forcer == true)
      set_param param_name, value
    else
      param_name = param_name.to_s
      if (@custom_params || {}).has_key?(param_name.to_sym)
        @custom_params ||= {}
        @custom_params[param_name.to_sym]
      elsif cgi.has_key? param_name
        val = real_value cgi[param_name]
        set_param param_name.to_sym, val
        return val
      elsif query_string.has_key? param_name.to_sym
        query_string param_name.to_sym
      elsif app.session[param_name.to_s]
        app.session[param_name.to_s]
      else
        nil
      end
    end
  end

  # {Hash} Retourne l'intégralité des paramètres
  # Utilisé dans certains cas seulement pour connaitre l'intégralité
  # des paramètres. Mais en règle générale, on n'en a pas besoin puisqu'on
  # ne lit que les paramètres dont on a besoin (comportement "lazzy")
  def all_params
    @all_params ||= begin
      h = params_session
      h.merge! params_querystrings
      h.merge! params_cgi
    end
  end

  def params_session
    @params_session ||= app.session.instance_variable_get('@data').to_sym
  end
  # Paramètres de l'url
  def params_querystrings
    @params_querystrings ||= get_query_strings
  end
  # Paramètres CGI (par exemple les données d'un formulaire POST)
  def params_cgi
    @params_cgi ||= begin
      h = Hash.new
      cgi.instance_variable_get('@params').keys.each { |key| h.merge!(key.to_sym => cgi[key]) }
      h
    end
  end

  REG_COMPLEXE_VALUES_CGI = /^(.*?)\[(.*?)\](?:\[(.*?)\])?$/
  def decomplexe_values_cgi
    @custom_params ||= Hash.new
    h_decomplexed = decomplexe_hash cgi.params
    @custom_params.merge! h_decomplexed
    @cgi_values_decomplexed = true
  end

  def decomplexe_hash h
    decomplexed = Hash.new
    h.each do |k, v|
      # puts "k: #{k.inspect}<br />v: #{v.inspect}".in_div
      if k.match REG_COMPLEXE_VALUES_CGI
        tout, key_objet, key1, key2 = k.match(REG_COMPLEXE_VALUES_CGI).to_a
        # puts "key_objet: #{key_objet}<br />key1: #{key1}<br />key2:#{key2.inspect}<br />".in_div

        real_value_for_hash = v.count > 1 ? v : v.first

        # La clé de l'objet, comme toutes les clés
        # est toujours symbolique
        #
        key_objet = key_objet.to_sym


        unless decomplexed.has_key? key_objet
          #
          # L'objet est un hash si sa première clé key1 n'est pas
          # un string vide. Note : dans le cas contraire, c'est un
          # Array.
          #
          objet_is_hash = key1 != ""
          #
          # Si l'objet (p.e. 'users') n'existe pas encore
          # dans les paramètres, on l'ajoute, avec sa clé (users ici)
          #
          decomplexed.merge!( key_objet => (objet_is_hash ? {} : []) )
        else
          objet_is_hash = decomplexed[key_objet].class == Hash
        end

        # On prend l'objet pour le traiter ensuite
        #
        objet = decomplexed[key_objet]

        # Si la clé 2 (key2) est NIL, c'est un ajout de
        # premier niveau. On peut le traiter et s'en
        # retourner à la valeur suivante
        #
        if key2.nil?
          if objet_is_hash
            objet.merge! key1.to_sym => real_value_for_hash
          else
            if v.count == 1
              decomplexed[key_objet] = v.first
            else
              v.each { |e| objet << e }
            end
          end
          next
        elsif key2 != nil # juste pour la clarté

          # On passe ici si key2 est défini

          # Une deuxième clé est définie, ce qui ne signifie pas
          # que l'objet est un hash, car si la première clé est un
          # nombre, c'est l'indice dans un array déjà créé.
          #
          if key1.numeric?
            case objet
            when Array, String
              if objet.class == String
                decomplexed[key_objet] = [objet.to_s]
                objet = decomplexed[key_objet]
              end
              # La 2e clé key2 va déterminer si on doit lui ajouter un autre
              # array (key2 == "") ou un hash
              if key2 == ""
                sous_objet = v
              elsif key2.numeric?
                raise "L'objet #{key_objet}[#{key1}] a trop de profondeur"
              else
                sous_objet = { key2.to_sym => real_value_for_hash }
              end
              objet << sous_objet
            when Hash
              key1 = key1.to_i
              unless objet.has_key? key1
                objet.merge! key1 => (key2 == "" ? [] : {} )
              end
              if key2 == ""
                v.each { |e| objet[key1] << e }
              else
                objet[key1].merge! key2.to_sym => real_value_for_hash
              end
            else
              raise "Objet inconnu : #{objet.class}"
            end
            next
          else # si key1 n'est pas un nombre
            #
            # Si key1 n'est pas un nombre mais que key2 est défini
            # c'est qu'il s'agit de la première définition d'un élément
            # de l'objet
            # objet[key1][] ou objet[key1][key2]
            # objet[][] ou objet[][key2]
            #
            case objet
            when Array
              if key2 == ""
                # Cas : objet[][]
                objet << v # on ajoute un array comme élément de l'array
              elsif key2.numeric?
                # Cas : objet[][3] # est-ce possible ?
                raise "Le cas #{key_objet}[][#{key2}] est impossible, normalement…"
              else
                # Cas : objet[][key2]
                # => C'est un hash qu'on doit ajouter comme élément
                #    de l'Array
                objet << {key2.to_sym => real_value_for_hash}
              end
            when Hash
              unless objet.has_key? key1.to_sym
                objet.merge! key1.to_sym => ( key2 == "" ? [] : {} )
              end
              if key2 == ""
                # Cas objet[key1][]
                v.each { |e| objet[key1.to_sym] << e }
              else
                # Cas objet[key1][key2]
                objet[key1.to_sym].merge! key2.to_sym => real_value_for_hash
              end
              next
            end
          end
        end
      else
        # Ne rien faire
      end
    end
    return decomplexed
  end

  #
  #
  # Retourne une valeur "réelle". Les "true", "false" et "nil" sont
  # remplacé par leur valeur non string
  #
  def real_value init_value
    case init_value
    when "true"         then true
    when "false"        then false
    when "nil", "null"  then nil
    else init_value
    end
  end

  # Décompose la donnée query-string de l'url
  def query_string param_name = nil
    @query_strings ||= get_query_strings
    if param_name.nil?
      @query_strings
    else
      @query_strings[param_name.to_sym]
    end
  end

  # Définit explicitement un paramètre
  def set_param added_params, value
    added_params = {added_params.to_sym => value} unless added_params.class == Hash
    @custom_params ||= Hash.new
    @custom_params = @custom_params.merge added_params
  end


  # Retourne tous les paramètres courants (à des fins de débug)
  #
  def all_params
    hparams = query_string
    cgi.params.each do |k, v|
      hparams.merge! "[cgi] #{k.inspect}" => v
    end
    # # Session ?
    # App::session.instance_variable_get('@hash').each do |k, v|
    #   hparams.merge! "[session] #{k.inspect}" => v
    # end
    hparams
  end

  # Méthode de débug qui met dans le trace.log tous les
  # paramètres courants
  #
  def debug_params
    tous_parametres = all_params
    tous_parametres.merge! (@custom_params || {})
    if tous_parametres.empty?
      debug "[Page::debug_params] Paramètres courants : AUCUN"
    else
      debug "[Page::debug_params] Paramètres courants : "
      all_params.each do |k,v|
        debug "#{k.inspect} => #{v.inspect} (class #{v.class})"
      end
    end
    debug "App::session.inspect : #{App::session.inspect}"
  end

  private

    def get_query_strings
      unless ENV['QUERY_STRING'].nil?
        ENV['QUERY_STRING'].dup.as_hash_from_query_string
      else
        Hash.new
      end
    end

end #/Page

class ::String
  # Méthode décomposant le query string envoyé pour
  # l'exploder en un hash non traité.
  def as_hash_from_query_string
    h = Hash.new
    self.split('&').each do |propvalue|
      key, value = propvalue.split('=')
      h.merge! key.to_sym => ( page.real_value( URI.unescape( value.to_s ) ) )
    end
    return h
  end
end
