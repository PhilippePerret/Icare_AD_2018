# encoding: UTF-8

def icmodule
  @icmodule ||= begin
    site.require_objet 'ic_module'
    IcModule.new(objet_id)
  end
end
def absmodule; @absmodule ||= icmodule.abs_module end
alias :abs_module :absmodule
