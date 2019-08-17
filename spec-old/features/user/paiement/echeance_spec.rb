=begin

  Ce module permet de controler le travail du CRON autour des échéances

=end

feature "Gestion des échéances de paiement" do
  before(:all) do
    FOLDER_CRON = './CRON'
    FOLDER_LIB  = File.join(FOLDER_CRON, 'lib')
    require './CRON/lib/required'
  end
  scenario 'Un icarien sans module n’est pas traité' do
    test 'Un icarien sans module n’est pas traité'
    start_time = Time.now.to_i - 1
    benoit.reset_all
    expect(benoit.icmodule).to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Dépassement d\'échéance de paiement'
    }
    Benoit ne recoit pas le mail data_mail
  end
  scenario 'Un icarien actif sans paiement ne reçoit rien' do
    start_time = Time.now.to_i - 1
    test 'Un icarien sans module n’est pas traité'
    benoit.reset_all
    benoit.set_actif(next_paiement: nil)
    expect(benoit.icmodule).not_to eq nil
    expect(benoit.icmodule.next_paiement).to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Dépassement d\'échéance de paiement'
    }
    Benoit ne recoit pas le mail data_mail
  end
  scenario 'Un icarien avec un paiement lointain ne reçoit rien' do
    start_time = Time.now.to_i - 1
    test 'Un icarien sans module n’est pas traité'
    benoit.reset_all
    benoit.set_actif(next_paiement: Time.now.to_i + 10.days)
    expect(benoit.icmodule).not_to eq nil
    expect(benoit.icmodule.next_paiement).not_to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Dépassement d\'échéance de paiement'
    }
    Benoit ne recoit pas le mail data_mail
  end
  scenario 'Un icarien avec un paiement à peine dépassé ne reçoit rien' do
    start_time = Time.now.to_i - 1
    test 'Un icarien sans module n’est pas traité'
    benoit.reset_all
    benoit.set_actif(next_paiement: Time.now.to_i - 2.days)
    expect(benoit.icmodule).not_to eq nil
    expect(benoit.icmodule.next_paiement).not_to eq nil
    cron.run_processus 'echeances'
    data_mail = {
      sent_after: start_time,
      subject: 'Dépassement d\'échéance de paiement'
    }
    Benoit ne recoit pas le mail data_mail
  end
  scenario 'Un icarien avec un dépassement de plus de 4 jours reçoit un premier avertissement' do
    start_time = Time.now.to_i - 1
    test 'Un icarien sans module n’est pas traité'
    expect(app.test?).to eq true
    benoit.reset_all
    benoit.set_actif(next_paiement: Time.now.to_i - 6.days)
    expect(benoit.icmodule).not_to eq nil
    expect(benoit.icmodule.next_paiement).to be < NOW - 5.days
    cron.run_processus 'echeances'

    # On récupère le log du cron pour voir les messages
    # puts Cron::Message.logs.inspect

    data_mail = {
      sent_after: start_time,
      subject: 'Dépassement d\'échéance de paiement'
    }
    Benoit recoit le mail data_mail
  end
end
