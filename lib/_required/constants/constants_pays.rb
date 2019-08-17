# encoding: UTF-8
=begin
Des constantes utiles
Cf. https://fr.wikipedia.org/wiki/Liste_des_codes_pays_utilisés_par_l%27OTAN
=end

PAYS = {
  'af'  => "Afrique",
  'ca'  => "Canada",
  'de'  => "Allemagne",
  'en'  => "Angleterre",
  'ar'  => "Arabie",
  'hy'  => "Arménie",
  'au'  => "Australie",
  'be'  => "Belgique",
  'zh'  => "Chine",
  'ko'  => "Corée",
  'ks'  => "Corée du Sud",
  'kn'  => "Corée du Nord",
  'hr'  => "Croatie",
  'da'  => "Danemark",
  'es'  => "Espagne",
  'et'  => "Estonie",
  'us'  => "États-Unis",
  'fi'  => "Finlande",
  'fr'  => "France",
  'gr'  => "Grèce",
  'hk'  => "Hong Kong",
  'hu'  => "Hongrie",
  'fj'  => "Îles Fiji",
  'hi'  => "Inde",
  'id'  => "Indonésie",
  'ga'  => "Irlande",
  'is'  => "Islande",
  'it'  => "Italie",
  'ja'  => "Japon",
  'no'  => "Norvège",
  'nz'  => "Nouvelle Zélande",
  'fa'  => "Perse",
  'pl'  => "Pologne",
  'pt'  => "Portugal",
  'cz'  => "République Tchèque",
  'ru'  => "Russie",
  'sw'  => "Suède",
  'ch'  => "Suisse",
  'cs'  => "Tchécoslovaquie"
}

PAYS_ARR_SELECT = PAYS.collect{|k, v| [k, v]}
