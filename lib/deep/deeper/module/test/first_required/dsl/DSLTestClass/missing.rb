# encoding: UTF-8
class DSLTestMethod


  def method_missing method_name, *args, &block
    mname = method_name.to_s
    if mname[0..2] == 'is_'

      for_not = mname.start_with?('is_not_')
      flat_meth   = method_name.to_s.sub(for_not ? /^is_not_/ : /^is_/,'')
      quest_meth  = "#{flat_meth}?".to_sym

      # Quand cette méthode est dans la test-méthode, il faut
      # que ce soit le "sujet" de cette test-méthode qui évalue
      # la méthode. Par exemple, dans test_user, le "sujet" doit
      # être l'user défini par le premier argument. Dans test_route,
      # le "sujet" doit être la page HTML donc l'objet `html`, dans
      # test_form, l'objet est le formulaire.
      if self.subject.respond_to?(quest_meth)
        # L'objet répond à une méthode correspondant à la
        # méthode appelée is_ ou is_not_. Il suffit donc de
        # l'appeler et de dire que le résultat doit être
        # soit true soif false puisque c'est la valeur qu'est
        # censée retourner une méthode '?'
        rs = self.subject.send(quest_meth)
        resultat = ( rs == !for_not )
        # On ajoute un message aux options dans le cas où
        # il n'aurait pas été défini, pour ne pas avoir le
        # message "true est égal à true"
        options = self.subject.defaultize_options(args[0], !for_not)
        options[:message] ||= begin
          if resultat
            if for_not
              "#{options[:sujet]} #{quest_meth.inspect} retourne faux (OK)."
            else
              "#{options[:sujet]} #{quest_meth.inspect} retourne vrai."
            end
          else
            if for_not
              "#{options[:sujet]} #{quest_meth.inspect} devrait être faux."
            else
              "#{options[:sujet]} #{quest_meth.inspect} devrait être vrai."
            end
          end
        end
        # On produit ensuite le test en fonction du
        # résultat
        rs.is(true, options)
      end
    elsif self.subject.respond_to?(method_name)
      if args.empty?
        self.subject.send(method_name)
      else
        self.subject.send(method_name, *args)
      end
    else
      if self.respond_to?(:self_method_missing)
        self.send(:self_method_missing, method_name)
      else
        raise "Méthode ou variable inconnue : #{method_name}"
      end
    end
  end
end #/class DSLTestClass
