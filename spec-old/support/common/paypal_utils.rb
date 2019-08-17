# encoding: UTF-8
=begin

=end

class TPayPal
class << self
  def page ; @page ||= Capybara.current_session end

  # Cette méthode peut être appelée juste après avoir cliqué sur un
  # bouton "Payer" conduisant à la page PayPal
  #
  # @usage
  #     TPayPal.do_operation_paypal(pseudo: benoit.pseudo, verbose: true)
  #
  def do_operation_paypal args

    pseudo  = args[:pseudo]
    verbose = !!args[:verbose]

    sleep 2
    until page.has_css?('body')
      verbose && puts("J'attends que la page réapparaisse…")
      sleep 1
    end
    sleep 2

    require './data/secret/data_benoit'

    verbose && puts("Benoit remplit le formulaire PayPal avec ses données…")
    code_javascript = <<-JS
var iframe;
for(iframe = 0; iframe < 4; ++iframe){
  if(window.frames[iframe].document.getElementById('email')){break}
}
var doc = window.frames[iframe].document;
doc.getElementById('email').value='#{DATA_BENOIT[:mail]}';
doc.getElementById('password').value='#{DATA_BENOIT[:password]}';
doc.getElementById('btnLogin').click();
    JS
    page.execute_script(code_javascript.gsub(/\n/,''))
    verbose && puts("Benoit attend de pouvoir confirmer le paiement…")
    sleep 2
    until page.has_css?('body')
      verbose && puts("J'attends que la page pour continuer apparaissent…")
      sleep 1
    end

    verbose && puts("Benoit attend 6 secondes")
    sleep 6
    # js_attente = "return document.getElementById('continue_abovefold');"
    # while page.execute_script(js_attente) == nil
    #   sleep 0.5
    # end
    # verbose && puts("Le bouton a été trouvé")
    # sleep 2
    # shot 'page-paypal-continuer'
    #
    # verbose && puts("Benoit clique le bouton “Continuer” pour procéder au paiement")
    require 'timeout'
    Timeout.timeout(20*60) do
      code_javascript = <<-JS
var nodes = document.getElementsByTagName('input');
for(var i=0,len=nodes.length;i<len;++i){
var node = nodes[i];
if(node.type=='submit'&&node.value=='Continuer'){node.click();break;}
}
      JS
      page.execute_script(code_javascript.gsub(/\n/,''))
      verbose && puts("Benoit attend qu'on revienne de PayPal…")
    end

    # On attend un peu que tout ait été fait
    sleep 4

  end
end #/<< self
end #/TPayPal
