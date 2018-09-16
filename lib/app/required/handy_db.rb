# encoding: UTF-8
=begin

  Méthodes pratiques pour les bases

=end

# Table des users

# = users =
def dbtable_users         ; @dbtusers   ||= sdbtbl_users('users')     end
def dbtable_paiements     ; @dbtpaimnts ||= sdbtbl_users('paiements') end
def dbtable_frigos        ; @dbtbl_frig ||= sdbtbl_users('frigos')    end
def dbtable_frigo_discussions
  @dbtbl_frigdisc ||= sdbtbl_users('frigo_discussions')
end
def dbtable_frigo_messages
  @dbtbl_frigmess ||= sdbtbl_users('frigo_messages')
end
# = hot =
def dbtable_watchers      ; @dbtwtchrs  ||= sdbtbl_hot('watchers')    end
def dbtable_actualites    ; @dbtactus   ||= sdbtbl_hot('actualites')  end
alias :dbtable_activites :dbtable_actualites
def dbtable_checkform     ; @dbtblchkf  ||= sdbtbl_hot('checkform')   end
def dbtable_connexions    ; @dbtbl_cons ||= sdbtbl_hot('connexions')  end

def dbtable_absmodules    ; @dbtabsmods ||= sdbt_mods('absmodules')   end
def dbtable_absetapes     ; @dbtabsetps ||= sdbt_mods('absetapes')    end
def dbtable_abswtypes     ; @dbtabswtyp ||= sdbt_mods('abs_travaux_type')  end
alias :dbtable_travaux_types :dbtable_abswtypes
def dbtable_icmodules     ; @dbticmods  ||= sdbt_mods('icmodules')    end
def dbtable_icetapes      ; @dbticetps  ||= sdbt_mods('icetapes')     end
def dbtable_icdocuments   ; @dbticdocs  ||= sdbt_mods('icdocuments')  end
def dbtable_minifaq       ; @dbtblmfaq  ||= sdbt_mods('mini_faq')     end
def dbtable_lectures      ; @dbtbllect  ||= sdbt_mods('lectures_qdd') end

def dbtable_temoignages   ; @dbtbltem   ||= sdbt_cold('temoignages')  end


# ---------------------------------------------------------------------
#   Fonctionnelles
# ---------------------------------------------------------------------
def sdbtbl base, name ; site.dbm_table(base, name)      end
def sdbtbl_users name ; site.dbm_table(:users, name)    end
def sdbtbl_hot name   ; site.dbm_table(:hot, name)      end
def sdbt_mods name    ; site.dbm_table(:modules, name)  end
def sdbt_cold name    ; site.dbm_table(:cold, name)     end
