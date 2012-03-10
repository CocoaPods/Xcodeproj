require 'xcodeproj/project/association/has_many'
require 'xcodeproj/project/association/has_one'
require 'xcodeproj/project/association/reflection'

module Xcodeproj
  class Project
    module Object

      class AbstractPBXObject
        class << self
          def has_many(plural_attr_name, options = {}, &block)
            create_association(:has_many, plural_attr_name, options, &block)
          end

          def has_one(singular_attr_name, options = {}, &block)
            create_association(:has_one, singular_attr_name, options)
          end

          private

          def create_association(type, name, options, &block)
            reflection = create_reflection(type, name, options)
            unless reflection.inverse?
              attribute(reflection.attribute_name, :as => reflection.attribute_getter)
            end
            define_method(reflection.getter) do
              reflection.association_for(self, &block).get
            end
            define_method(reflection.setter) do |new_value|
              reflection.association_for(self, &block).set(new_value)
            end
          end
        end
      end

      class Association
        attr_reader :owner, :reflection

        def initialize(owner, reflection, &block)
          @owner, @reflection, @block = owner, reflection, block
        end

        def get
          @reflection.inverse? ? inverse_get : direct_get
        end

        def set(value)
          @reflection.inverse? ? inverse_set(value) : direct_set(value)
        end
      end

    end
  end
end
