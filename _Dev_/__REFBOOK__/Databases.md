# Bases de données

* [Introduction](#introduction)
* [Raccourcis de noms de table](#raccourcisdenomdetable)


<a name='introduction'></a>

## Introduction

Dans la nouvelle formule de l'atelier Icare, toutes les données sont consignées dans des bases MySQL.



<a name='raccourcisdenomdetable'></a>

## Raccourcis de noms de table

Des raccourcis simples existent pour chaque tache, qui n'obligent pas d'utiliser chaque fois `site.dbm_table(base, table_name)`. Ils sont définis dans le fichier :

    ./\_lib/handy/handy_db.rb

Ces noms sont simplement construits par :

    dbtable_<désignation>

Par exemple :

    dbtable_users         # => table des users
    dbtable_watchers      # => table des watchers
    dbtable_paiements     # => table des paiements
    etc.
