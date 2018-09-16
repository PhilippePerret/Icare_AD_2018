# encoding: UTF-8
class Ajax
  class << self

    # Envoi du code
    def output
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      begin
        STDOUT.write (data || Hash.new).to_json
      rescue Exception => e
        # Parfois, le code ne peut pas être traduit, à cause de
        # ce PU***N de problème d'encodage US8bit vers UTF8
        fdata = force_encoding(data, 'utf-8')
        STDOUT.write fdata.to_json
      end
    end

    def force_encoding foo, format
      case foo
      when String then foo.force_encoding(format)
      when Hash   then force_encoding_hash(foo, format)
      when Array  then force_encoding_array(foo, format)
      else foo
      end
    end
    def force_encoding_hash hash, format
      newh = Hash.new
      hash.each do |k, v|
        v = force_encoding(v, format)
        newh.merge!(k => v)
      end
      return newh
    end
    def force_encoding_array foo, format
      foo.collect { |v| force_encoding(v, format) }
    end

    # Ajoute une donnée à retourner
    #
    # TODO Plus tard, faire un merge "intelligent" avec les messages,
    # pour que les nouveaux messages ou erreurs n'écrasent pas les
    # messages ou erreurs existants.
    def << hdata
      @data ||= Hash.new
      @data.merge!( hdata )
    end

    # Données à retourner à la requête
    def data
      @data ||= Hash.new
      # S'il y a des messages, il faut les ajouter
      if app.notice.output != ''
        flash @data[:message] if @data.key?(:message)
        @data.merge!(message: app.notice.output)
      end
      if app.error.output != ''
        error @data[:error] if @data.key?(:error)
        @data.merge!(error: app.error.output)
      end
      return @data
    end

  end # /<< self
end #/Ajax
