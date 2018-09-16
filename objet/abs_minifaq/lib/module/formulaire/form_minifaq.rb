# encoding: UTF-8
=begin

  Formulaire pour la minifaq

=end
class AbsMinifaq
class << self

  # Le formulaire pour poser une nouvelle question
  # @usage    AbsMinifaq.formulaire(abs_etape)
  #
  # +abs_etape+ L'AbsEtape pour laquelle on doit installer le formulaire
  def formulaire abs_etape
    (
      (
        'Question'.in_span(class: 'libelle') +
        (param(:minifaq_question) || '').in_textarea(row: '6', name: 'minifaq[question]', placeholder: 'Si vous avez une autre question sur cette étape, vous pouvez la poser ici.').in_span(class: 'value')
      ).in_div(class: 'row') +
      abs_etape.id.to_s.in_hidden(name: 'minifaq[abs_etape_id]') +
      'Poser cette question'.in_submit(class: '').in_div(class: 'buttons')
    ).in_form(id: 'minifaq_form', class: 'dim3070', action: 'abs_minifaq/new_question')
  end

end # << self
end # AbsMinifaq
