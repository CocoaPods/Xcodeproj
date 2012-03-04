# encoding: utf-8
require 'yard/handlers/ruby/base'
require 'yard/core_ext/symbol_hash'

require File.expand_path('../lib/xcodeproj/inflector', __FILE__)

class PBXObjectAttributeHandler < YARD::Handlers::Ruby::Base
  handles method_call(:attribute)
  namespace_only

  def process
    if comments = statement.comments
      # Matches: "[type] description"
      # Should not end with a dot.
      type, description = comments.match(/^\[(.+?)\]\s+(.+?)$/).to_a.last(2)
    end
    type ||= 'Object'

    snake_case_name = statement.parameters(false).jump(:ident).source
    camelized_name = snake_case_name.camelize(:lower)

    { :read => snake_case_name, :write => "#{snake_case_name}=" }.each do |accessor_type, method|
      MethodObject.new(namespace, method, scope) do |o|
        doc = []
        if accessor_type == :write
          o.parameters = [['value', nil]]
          if description
            doc << "Assigns #{description}."
          else
            doc << "Assigns the `attributes` value for key ‘`#{camelized_name}`’."
          end
          doc << "@param [#{type}] value The value to assign to the `attributes` value for key ‘`#{camelized_name}`’ to."
          doc << "@return [#{type}] The value."
        else
          if description
            doc << "Returns #{description}."
            doc << "@return [#{type}]  The `attributes` value for key ‘`#{camelized_name}`’."
          else
            doc << "@return [#{type}]  Returns the `attributes` value for key ‘`#{camelized_name}`’."
          end
        end
        o.docstring = doc.join("\n")
        o.visibility = visibility
      end
    end
  end
end
