# encoding: UTF-8

class Fixnum

  # Affirme que le nombre courant est égal au nombre
  # passé en argument
  def eq compared, options=nil, inverse=nil
    options ||= {}
    option_evaluate = options.delete(:evaluate)
    option_strict   = !!options.delete(:strict)

    ok = option_strict ? ( self === compared ) : ( self == compared )

    strictly = option_strict ? "strictement " : ""

    option_evaluate && ( return ok )

    SiteHtml::TestSuite::Case::new(
      SiteHtml::TestSuite::current_test_method,
      result:           ok,
      positif:          !inverse,
      sujet:            options.delete(:sujet),
      sujet_valeur:     self,
      objet:            options.delete(:objet),
      objet_valeur:     compared,
      on_success:       "_SUJET_ est #{strictly}égal _OBJET_.",
      on_success_not:   "_SUJET_ n'est pas #{strictly}égal _OBJET_ (OK).",
      on_failure:       "_SUJET_ devrait être #{strictly}égal _OBJET_, il est égal à #{self}…",
      on_failure_not:   "_SUJET_ ne devrait pas être #{strictly}égal _OBJET_."
    ).evaluate
  end
  def not_eq( compared, options=nil )
    eq compared, options, true
  end
  def eq?( compared, options=nil )
    eq compared, (options || {}).merge(evaluate: true)
  end
  def not_eq?( compared, options=nil )
    eq compared, (options || {}).merge(evaluate: true), true
  end

  def bigger_than expected, options=nil, inverse=false
    options ||= {}
    option_evaluate = options.delete(:evaluate)
    option_strict   = !!options.delete(:strict)

    ok = option_strict ? ( self > expected ) : ( self >= expected )

    option_evaluate && ( return ok )

    strictly = option_strict ? "strictement " : ""

    SiteHtml::TestSuite::Case::new(
      SiteHtml::TestSuite::current_test_method,
      result:           ok,
      positif:          !inverse,
      sujet:            options.delete(:sujet),
      sujet_valeur:     self,
      objet:            options.delete(:objet),
      objet_valeur:     expected,
      on_success:       "_SUJET_ est #{strictly}supérieur _OBJET_.",
      on_success_not:   "_SUJET_ n'est pas #{strictly}supérieur _OBJET_ (OK).",
      on_failure:       "_SUJET_ devrait être #{strictly}supérieur _OBJET_, il est égal à #{self}…",
      on_failure_not:   "_SUJET_ ne devrait pas être #{strictly}supérieur _OBJET_."
    ).evaluate
  end
  def not_bigger_than(expected, options=nil)
    bigger_than expected, options, true
  end
  def bigger_than?(expected, options=nil)
    bigger_than expected, (options || {}).merge(evaluate: true)
  end
  def not_bigger_than?(expected, options=nil)
    bigger_than expected, (options || {}).merge(evaluate: true), true
  end

  def smaller_than

  end
end
