# encoding: UTF-8
=begin

  Aide complète pour la rédaction des fichiers Markdown qui seront
  traités par Kramdown étendu.

=end
raise_unless_admin

class SiteHtml
class Admin
class Console

  def aide_redaction_markdown
    sub_log texte_aide_redaction
  end

  def texte_aide_redaction
    <<-HTML
&nbsp;</div><!-- pour clore la balise sub_log -->

<p>Insérer le code suivant dans le document pour utiliser les fonctions de rédaction ci-dessous :</p>
<pre>
  <code>site.require_module 'kramdown'</code>
  <code>SuperFile::new("path/to/the/file.md").kramdown</code>
  <code># => Produit le code HTML du fichier</code>
</pre>


<h3>Citation d'auteur</h3>
<pre>
  >> "la citation entre guillemets double" Auteur[ - Source]
</pre>
<p class='small'>Correspond à la classe CSS <code>`quote`</code>.</p>


<h3>Texte en exergue dans un encart</h3>
<pre>
  [Le texte qui sera mis en exergue dans un cadre]
</pre>
<p>
  Note : Dans un texte en exergue, les retours à la ligne doivent être signifiés par <code>`&lt;br>`</code> ou <code>`\\n`</code> (pas le retour chariot slash-N mais un vrai caractère balance et un “n”).
</p>
<p class='small'>Correspond à la classe CSS <code>`exergue`</code></p>


<h3>Environnement documents</h3>
<pre>
  DOC/&lt;synopsis|events|scenario|rapport>[ plain][ &lt;autres classes>]
  # &lt;grand titre>
  ## &lt;titre>

  / &lt;légende du document>
  /DOC
</pre>

<p>Retraits de paragraphe : tabulation ou double-espaces.</p>
<pre>
  DOC/synopsis
  ..Un texte en retrait de 1
  \\t\\tUn texte en retrait de 2
  ......Un texte en retrait de 3
</pre>

<p class='small'>
  Pour plus de détails, voir le fichier d'aide `./__Dev__/__RefBook_Utilisation__/Vues/Formats_fichiers/markdown_extra.md`.
</p>
<div><!-- pour la balise sub_log de fermeture générale -->
    HTML
  end

end #/Console
end #/Admin
end #/SiteHtml
