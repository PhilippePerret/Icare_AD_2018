LEGEND "CANDIDATURE"
FORM id:'validate_canditature' protected:true
  MAIN_DIV    "Attributer à <%= owner.ref %> le module :"
  DIV         "<%= menu_modules %>"
  SMALL_DIV   "(les modules choisis par le candidat sont entre <q>***</q>)"
  DIV id:id_div_refus display:'none'
    DIV       "Ou refuser l'inscription au motif de"
    TEXTAREA  name:'refus[motif]' id:'motif_refus'
    CHECKBOX "Format ERB (HTML évalué)" name:'refus[format]' id:'refus_format'
  BUTTONS
    LEFT
      A 'Download présentation' href:"admin/operation?opadmin=download_signup&sid=#{data}"
    SUBMIT "OK"
