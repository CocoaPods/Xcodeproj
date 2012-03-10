require 'xcodeproj/project/association_reflection'

module Xcodeproj
  class Project
    module Object

      class AbstractPBXObject
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

          class HasMany < Association
            def direct_get
              uuids = @owner.send(@reflection.attribute_getter)
              if @block
                # Evaluate the block, which was specified at the class level, in
                # the instance’s context.
                @owner.list_by_class(uuids, @reflection.klass) do |new_object|
                  @owner.instance_exec(new_object, &@block)
                end
              else
                @owner.list_by_class(uuids, @reflection.klass)
              end
            end

            def inverse_get
              scoped = @owner.project.objects.select_by_class(@reflection.klass).select do |object|
                object.send(@reflection.inverse.attribute_getter) == @owner.uuid
              end
              PBXObjectList.new(@reflection.klass, @owner.project, scoped) do |new_object|
                new_object.send(@reflection.inverse.attribute_setter, @owner.uuid)
              end
            end

            # @todo Currently this does not call the @block, which means that
            #       in theory (like with a group's children) the object stays
            #       asociated with its old group.
            def direct_set(list)
              @owner.send(@reflection.attribute_setter, list.map(&:uuid))
            end

            def inverse_set(list)
              raise NotImplementedError
            end
          end

          # @todo Does this need 'new object'-callback support too?
          class HasOne < Association
            def direct_get
              @owner.project.objects[@owner.send(@reflection.attribute_getter)]
            end

            def inverse_get
              # Loop over all objects of the class and find the one that includes
              # this object in the specified uuid list.
              @owner.project.objects.select_by_class(@reflection.klass).find do |object|
                object.send(@reflection.inverse.attribute_getter).include?(@owner.uuid)
              end
            end

            def direct_set(object)
              @owner.send(@reflection.attribute_setter, object.uuid)
            end

            def inverse_set(object)
              # Remove this object from the uuid list of the target
              # that this object was associated to.
              if previous = @owner.send(@reflection.name)
                previous.send(@reflection.inverse.attribute_getter).delete(@owner.uuid)
              end
              # Now assign this object to the new object
              object.send(@reflection.inverse.attribute_getter) << @owner.uuid if object
            end
          end
        end

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

    end
  end
end
