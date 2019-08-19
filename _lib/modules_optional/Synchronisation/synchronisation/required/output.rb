# encoding: UTF-8
=begin

Méthodes utiles pour la sortie du document au format HTML

=end
class Synchro
class Output

  ##
  ## L'instance Synchro
  ##
  attr_reader :synchro

  def initialize isynchro
    @synchro = isynchro
  end

  ##
  #
  # = main =
  #
  # Construction du fichier HTML de résultat
  #
  #
  def build_html_file
    reset_variables
    delete_file_prov
    traite_resultat
    open_document
    add_statistiques
    add_rows_desynchronised_files
    add_all_rows
    close_document
    delete_file_prov
  end

  def reset_variables
    @desynchronized_rows = ""
    @desynchronized_count = 0
    @file_count = result.count
  end

  ##
  #
  # Ajoute les résultats chiffrés
  #
  #
  def add_statistiques
    write <<-HTML
<fieldset>
  <legend>Statistiques</legend>
  <div id="div_file_count">
    <span>Nombre de fichiers traités : </span><span>#{@file_count}</span>
  </div>
  <div id="div_desynchronized_count">
    <span>Nombre de fichiers désynchronisés : </span><span>#{@desynchronized_count}</span>
  </div>
</fieldset>
    HTML
  end
  ##
  #
  # Ajoute au document HTML les rangées de fichiers désynchronisés
  #
  # NOTE : Ils ont été collectés au cours de `traite_resultat'
  #
  def add_rows_desynchronised_files
    write "<h2>Fichiers désynchronisés</h2>"
    write first_row
    write row_button_synchronize_all if @desynchronized_count >= 3
    write "<div id='desynchronizeds'>" + @desynchronized_rows + '</div>'
  end

  # La rangée avec le bouton pour tout synchroniser
  def row_button_synchronize_all
    "<div style='text-align:right;padding:8px;'>"+
      '<input type="checkbox" id="cb_destroy_distant">&nbsp;<label for="cb_destroy_distant">Détruire les distants</label>' +
      '<input type="button" value="Tout synchroniser et détruire" style="background-color:#00cb00;color:#ffffff;font-size:inherit;padding:4px 12px 3px;" onclick="$.proxy(Synchro,\'synchronize_all\')()" />' +
    '</div>'
  end

  ##
  #
  # Ajoute au document HTML toutes les rangées collectées
  #
  def add_all_rows
    write "<h2>Tous les fichiers</h2>"
    write first_row
    write File.read(path_html_file_prov)
  end


  def delete_file_prov
    File.unlink path_html_file_prov if File.exists? path_html_file_prov
  end

  def open_document
    write "<!DOCTYPE html>"
    write head_html
    write titre
  end

  def close_document
    write "</body></html>"
    reffile.close
  end
  ##
  #
  # Écrit dans le fichier HTML
  #
  #
  def write str
    reffile.write str
  end

  ##
  #
  # Écrit  la rangée +row+ (code HTML) dans le fichier
  # provisoire contenant toutes les rangées (qui ne sera ajouté qu'à
  # la fin)
  #
  def write_row row
    reffile_prov.write row
  end

  ##
  #
  # Référence au fichier HTML
  #
  def reffile
    @reffile ||= File.open(path_html_file, 'a')
  end

  ##
  #
  # Référence au fichier HTML provisoire contenant seulement
  # toutes les rangées (qui seront insérées à la fin)
  #
  def reffile_prov
    @reffile_prov ||= File.open(path_html_file_prov, 'a')
  end


  def traite_resultat
    result.sort
    result.each do |file_path, file_data|
      sfile = SFile::new file_path, file_data
      unless sfile.time_ok?
        @desynchronized_rows << sfile.row
        @desynchronized_count += 1
      end
      write_row sfile.row
    end
  end


  def now_humain
    @now_humain ||= Time.now.strftime("%d %m %Y - %H:%M")
  end

  # = raccourcis =
  def path_html_file; @path_html_file ||= synchro.path_html_file  end
  def result;         @result         ||= synchro.result          end

  def path_html_file_prov
    @path_html_file_prov ||= File.join(synchro.folder, 'output', 'rows-prov.html')
  end

  def head_html
    <<-HTML
<html>
<head>
  <meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <title>Check synchro #{now_humain}</title>
  <base href="#{synchro.base}" />
  <style type="text/css">#{styles.gsub(/\n/,'')}</style>
  #{javascript}
</head>
<body>
  <input type="hidden" name="ajax_url" id="ajax_url" value="#{FOLDER_SYNCHRONISATION_RELPATH}/output/ajax.rb" />
    HTML
  end

  def styles
    <<-CSS
body {
  width:1300px;
  font-size:13.4pt;
}
div#flash {position:fixed; left:2em; top:1em; background-color: teal;
  padding:1em;
  color:white;}
div.row {
  margin-bottom:4px;
}
div.row.titre {font-weight: bold; font-size: 15pt;}
div.col.fname {width: 60%}
div.col.local, div.col.distant {width: 18%; float: right; font-size: 10pt;}
div.col a {
  text-decoration: none;
  border: 1px solid;
  margin-right: 4px;
  float:left;
  color: white;
  padding: 0 4px;
  font-size: 12.0pt;
}
div.col a.destroy {background-color: red}
div.col a.download, div.col a.upload {background-color: teal}

div.row.ok {
  background-color: #CFC;
}
div.row.err {
  background-color: #FCC;
}
    CSS
  end

  ##
  #
  # @return le code pour le titre du document
  #
  def titre
    "<h1>Check synchro ONLINE / OFFLINE du #{now_humain}</h1>"
  end

  def first_row
    <<-HTML
<div class='row titre'>
  <div class='col distant'>ONLINE</div>
  <div class='col local'>OFFLINE</div>
  <div class='col fname'>Fichier</div>
</div>
    HTML
  end

  def javascript
    c = ""
    c << tags_scripts_js( Dir["#{folder_js_first_required}/**/*.js"] )
    c << tags_scripts_js( Dir["#{FOLDER_SYNCHRONISATION}/**/*.js"], true)
    c << tags_scripts_js( Dir["#{folder_js_required}/**/*.js"] )
    return c
  end

  def tags_scripts_js fullpath_list, strict = false
    return "" if fullpath_list.nil? || fullpath_list.empty?
    fullpath_list.collect do |path|
      path =
        if strict
          path.sub(/^#{File.expand_path('.')}/,'.')
        else
          path
        end
      "<script src='#{path}' type='text/javascript' charset='utf-8'></script>"
    end.join("\n")
  end

  def folder_js_first_required
    @folder_js_first_required ||= File.join(synchro.javascript_folder, 'first_required')
  end
  def folder_js_required
    @folder_js_required ||= File.join(synchro.javascript_folder, 'required')
  end

end # Output
end # Synchro
