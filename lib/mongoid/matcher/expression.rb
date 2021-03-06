module Mongoid
  module Matcher

    # @api private
    module Expression
      module_function def matches?(document, expr)
        expr.all? do |k, expr_v|
          k = k.to_s
          if k.start_with?('$')
            ExpressionOperator.get(k).matches?(document, expr_v)
          else
            value, expanded = Matcher.extract_attribute(document, k)
            # The value may have been expanded into an array, but then
            # array may have been shrunk back to a scalar (or hash) when
            # path contained a numeric position.
            # Do not treat a hash as an array here (both are iterable).
            if expanded && Array === value
              value.any? do |v|
                FieldExpression.matches?(true, v, expr_v)
              end
            else
              FieldExpression.matches?(!value.nil?, value, expr_v)
            end
          end
        end
      end
    end
  end
end
