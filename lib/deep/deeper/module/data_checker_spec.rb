# encoding: UTF-8

require_relative 'data_checker'
include DataChecker

describe 'DataChecker' do

  # Définit @objet (l'objet à checker) et @defcheck (définition du
  # check à opérer) puis tester `result` qui contient l'instance
  # data_check (prendre result.objet pour tester l'objet)
  let(:result) { @result ||= @objet.check_data(@defcheck) }
  let(:objet) { @objet }

  describe 'transforme les valeurs' do
    describe 'Epure les valeurs string de l’objet' do
      before(:each) do
        @init_value     = " valeur impure \n\n"
        @correct_value  = @init_value.nil_if_empty
        @objet = {var: @init_value}
        @defcheck = {}
      end
      it 'épure les valeurs de l’objet' do
        newobj = result.objet
        expect(result.ok).to eq true
        expect(newobj[:var]).not_to  eq @init_value
        expect(newobj[:var]).to      eq @correct_value
      end
    end
    describe 'quand il trouve des valeurs vides ou pseudo-vides' do
      before(:each) do
        @objet     = {var: "", var_string:"un string", varvide: "\n\n \r"}
        @defcheck  = {}
      end
      it 'les met à nil' do
        res = result.objet
        expect(res[:var]).not_to eq ""
        expect(res[:var]).to eq nil
        expect(res[:var_string]).not_to eq nil
        expect(res[:var_string]).to eq "un string"
        expect(res[:varvide]).to eq nil
      end
    end
    describe 'quand il y a des types :fixnum, :float ou :bignum' do
      before(:all) do
        @defcheck = {
          var_fixnum:   {type: :fixnum},
          var_nil:      {type: :fixnum},
          var_float:    {type: :float},
          var_string:   {type: :string}
        }
        @objet = {var_nil: "", var_fixnum: " 12", var_float: " 12.20 ", var_string:"Un string"}
      end
      it 'transforme les types :fixnum en fixnum' do
        expect(result.objet[:var_fixnum]).to eq 12
      end
      it 'transforme les types :float en float' do
        expect(result.objet[:var_float]).to eq 12.20
      end
      it 'ne transforme pas les types :string en nombre' do
        expect(result.objet[:var_string]).to eq "Un string"
      end
      it 'ne traite pas les valeurs nil' do
        expect(result.objet[:var_nil]).not_to eq 0
        expect(result.objet[:var_nil]).to eq nil
      end
    end
  end

  describe 'check les valeurs' do
    context 'avec un nombre non défini' do
      before(:each) do
        @objet = {nombre: ""}
        @defcheck = {nombre: {type: :fixnum, defined: true}}
      end
      it 'produit une erreur' do
        expect(result.ok).to eq false
      end
      it 'retourne le message d’erreur' do
        expect(result.errors).to have_key :nombre
        expect(result.errors[:nombre][:err_message]).to eq "La valeur de :nombre doit être définie."
      end
    end

  end

  describe 'check du minimum' do
    context 'avec un string' do
      context 'trop court' do
        before(:each) do
          @objet    = {texte: "Trop court"}
          @defcheck = {texte: {hname: "texte", type: :string, min: 20}}
        end
        it 'produit une erreur' do
          expect(result.ok).to eq false
        end
        it 'retourne un message valide' do
          expect(result.errors).to have_key(:texte)
          expect(result.errors[:texte][:err_message]).to eq "La valeur de texte devrait avoir une longueur minimum de 20 (la longueur est de 10)."
        end
      end
      context 'assez long' do
        before(:each) do
          @objet = {text: "Le texte assez long."}
          @defcheck = {text: {type: :string, min: 10}}
        end
        it 'ne produit pas d’erreur' do
          expect(result.ok).to eq true
        end
      end
    end
    context 'avec un nombre :fixnum trop petit' do
      before(:each) do
        @objet    = {nombre: "5"}
        @defcheck = {nombre: {hname: "nombre", type: :fixnum, min: 6}}
      end
      it 'produit une erreur' do
        expect(result.ok).to eq false
      end
      it 'retourne un message valide' do
        expect(result.errors).to have_key(:nombre)
        expect(result.errors[:nombre][:err_message]).to eq "La valeur de nombre devrait être supérieur ou égal à 6 (sa valeur est de 5)."
      end
    end
    context 'avec un nombre :fixnum assez grand' do
      before(:all) do
        @objet    = {nombre: "7"}
        @defcheck = {nombre: {hname: "Le nombre", type: :fixnum, min: 6}}
      end
      it 'ne produit pas d’erreur' do
        expect(result.ok).to eq true
      end
    end
  end

  describe 'Check du maximum' do
    context 'avec un nombre' do
      context 'trop grand' do
        before(:each) do
          @objet = {nombre: 100}
          @defcheck = {nombre: {type: :fixnum, hname: "nombre", max: 50}}
        end
        it 'produit une erreur' do
          expect(result.ok).to eq false
        end
        it 'retourne le bon message' do
          expect(result.errors[:nombre][:err_message]).to eq "La valeur de nombre devrait être inférieur ou égal à 50 (sa valeur est de 100)."
        end
      end
      context 'assez court' do
        before(:each) do
          @objet = {nombre: 100}
          @defcheck = {nombre: {type: :fixnum, max: 100}}
        end
        it 'ne produit pas d’erreur' do
          expect(result.ok).to eq true
        end
      end
    end

    context 'avec un string' do
      context 'trop long' do
        before(:each) do
          @objet = {texte: "Le texte trop long."}
          @defcheck = {texte: {hname: "texte", type: :string, max: 10}}
        end
        it 'produit une erreur' do
          expect(result.ok).to eq false
        end
        it 'retourne le bon message d’erreur' do
          expect(result.errors[:texte][:err_message]).to eq "La valeur de texte devrait avoir une longueur maximale de 10 (la longueur est de 19)."
        end
      end
      context 'pas trop long' do
        before(:all) do
          @objet = {texte: "Bon"}
          @defcheck = {texte: {type: :string, max: 50}}
        end
        it 'ne produit pas d’erreur' do
          expect(result.ok).to eq true
        end
      end
    end
  end

  describe 'Check d’un mail' do
    context 'avec une donnée string valide' do
      before(:all) do
        @objet = {monmail: "unmailvalide@chez.moi"}
        @defcheck = { monmail: {type: :mail} }
      end
      it 'ne produit pas d’erreur' do
        expect(result.ok).to eq true
      end
    end
    context 'avec une donnée mail invalide' do
      [
        "un mauvais mail",
        "un!mauvais!@mail.com",
        "un@mauvais",
        "un.mauvais"
      ].each do |badmail|
        it "produit une erreur avec le mail “#{badmail}”" do
          @objet = {monmail: badmail}
          @defcheck = {monmail: {type: :mail}}
          expect(result.ok).to eq false
        end
        it 'retourne le bon message d’erreur' do
          @objet = {monmail: badmail}
          @defcheck = {monmail: {type: :mail}}
          expect(result.errors[:monmail][:err_message]).to eq "Le mail “#{badmail}” est invalide."
          expect(result.errors[:monmail][:err_code]).to eq 30000
        end
      end
    end
  end
end
