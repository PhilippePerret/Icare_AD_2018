# encoding: UTF-8

def icdocument    ; @icdocument   ||= instance_objet            end
def icetape       ; @icetape      ||= icdocument.icetape        end
def icmodule      ; @icmodule     ||= icdocument.icmodule       end
def module_name   ; @module_name  ||= icmodule.abs_module.name  end
def numero_etape  ; @numero_etape ||= icetape.abs_etape.numero  end
