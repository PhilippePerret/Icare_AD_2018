=begin

  Test de l'envoi d'un mail en cas de dépassement d'échéance de
  rendu de travail.

=end
feature "Un mail est envoyé lorsqu'une échéance de travail est dépassée" do
  before(:all) do
    FOLDER_CRON = './CRON'
    FOLDER_LIB  = File.join(FOLDER_CRON, 'lib')
    require './CRON/lib/required'
  end
  scenario 'L’icarien ne reçoit pas de mail s’il n’est pas actif' do
    test 'L’icarien ne reçoit pas de mail s’il n’est pas actif'
    start_time = Time.now.to_i - 1
    benoit.reset_all
    expect(benoit.icmodule).to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Échéance de travail d’étape dépassée'
    }
    Benoit ne recoit pas le mail data_mail
  end

  scenario 'L’icarien ne reçoit pas de mail s’il n’est pas en retard' do
    start_time = Time.now.to_i - 1
    test 'L’icarien ne reçoit pas de mail s’il n’est pas en retard'
    benoit.reset_all
    benoit.set_actif(next_paiement: nil)
    expect(benoit.icmodule).not_to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Échéance de travail d’étape dépassée'
    }
    Benoit ne recoit pas le mail data_mail
  end

  scenario 'L’icarien reçoit un mail s’il est en dépassement d’échéance' do
    start_time = Time.now.to_i - 1
    test 'L’icarien ne reçoit pas de mail s’il n’est pas en retard'
    benoit.reset_all
    benoit.set_actif(next_paiement: nil)
    expect(benoit.options[16].to_i).to eq 2
    hbenoit = dbtable_users.get(benoit.id)
    expect(hbenoit[:options][16].to_i).to eq 2

    # On met son échéance d'étape à il y a 5 jours
    benoit.icetape.set(expected_end: NOW - 8.days)

    # === TEST ===
    cron.run_processus 'echeances'

    expect(Cron::Message.logs).not_to eq nil
    success 'Des messages logs ont été produits par le cron-job'
    # puts Cron::Message.logs.pretty_inspect

    # === VÉRIFICATION ===
    data_mail = {
      sent_after: start_time,
      subject: 'Échéance de travail d’étape dépassée'
    }
    Benoit recoit le mail data_mail
  end
end
