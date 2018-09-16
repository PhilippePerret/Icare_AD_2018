# encoding: UTF-8
=begin

  Module principal qui run un watcher c'est-à-dire qui accomplit son
  fichier `main.rb` s'il existe (mais normalement il doit exister) et
  envoie les mails.

=end
woid = site.current_route.objet_id
app.benchmark("-> watcher/run.rb (watcher ##{woid})")

begin
  SiteHtml::Watcher.new(site.current_route.objet_id).run
rescue Exception => e
  debug e
  error e.message
ensure
  # Dans tous les cas, quoi qu'il se passe, on revient à la route
  # précédente
  redirect_to :last_route
end
app.benchmark("<- watcher/run.rb (watcher ##{woid})")
