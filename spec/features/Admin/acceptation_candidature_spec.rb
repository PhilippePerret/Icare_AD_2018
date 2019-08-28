# encoding: UTF-8
=begin

  Test de l'acceptation de la candidature par un administrateur

=end
feature "Acceptation de la candidature" do

  context 'avec un candidat n’ayant pas confirmé son mail', current:true do
    scenario 'L’administrateur ne peut pas valider la candidature' do
      create_candidature(mail_confirmed: false)

      # L'administrateur rejoint le site
      visit('/')
      identify_phil

      # Pour être sûr qu'il se rende dans son bureau
      visit('/bureau')
      sleep 30

    end
  end

  context 'avec un candidat ayant confirmé son mail' do
    scenario 'l’administrateur peut valider la candidature' do
      create_candidature(mail_confirmed: true)
      pending
    end
  end
end
