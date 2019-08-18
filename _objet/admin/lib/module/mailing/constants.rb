# encoding: UTF-8
class Admin
class Mailing

  KEYS_DESTINATAIRES = {
    :all        => {hname: 'À tous les icariens',     checked: nil},
    :actif      => {hname: 'Aux icariens actifs',     checked: nil},
    :ancien     => {hname: 'Aux anciens icariens',    checked: nil},
    :enpause    => {hname: 'Aux icariens en pause',   checked: nil},
    :alessai    => {hname: 'Aux icariens à l’essai',  checked: nil},
    :real       => {hname: 'Aux vrais icariens',      checked: nil},
    :admin      => {hname: 'Aux administrateurs',     checked: nil}
  }

  OPTIONS = {
    :signature_bot  => {hname: "Signature du bot (sinon, la mienne)", value: nil},
    :code_brut      => {hname: "Le message est en pur code HTML",    value: nil},
    :code_erb       => {hname: "Code ERB (donc HTML)", value: nil},
    :no_template    => {hname: "Ne pas interpréter les '%'", value: nil}

  }
  if OFFLINE
    OPTIONS.merge! :force_offline => {hname: "Forcer l'envoi même en OFFLINE", value: nil}
  end

end #/Mailing
end #/Admin
