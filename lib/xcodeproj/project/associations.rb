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

          class HasMany < Association
            def get
              uuids = @owner.send(reflection.uuids_getter)
              if @block
                # Evaluate the block, which was specified at the class level, in
                # the instance’s context.
                @owner.list_by_class(uuids, reflection.klass) do |new_object|
                  @owner.instance_exec(new_object, &@block)
                end
              else
                @owner.list_by_class(uuids, @reflection.klass)
              end
            end

            # @todo Currently this does not call the @block, which means that
            #       in theory (like with a group's children) the object stays
            #       asociated with its old group.
            def set(list)
              @owner.send(@reflection.uuids_setter, list.map(&:uuid))
            end
          end

          # @todo Does this need 'new object'-callback support too?
          class HasOne < Association
            def get
              @owner.project.objects[@owner.send(@reflection.uuid_getter)]
            end

            def set(object)
              @owner.send(@reflection.uuid_setter, object.uuid)
            end
          end
        end

        def self.has_many(plural_attr_name, options = {}, &block)
          reflection = create_reflection(plural_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              scoped = @project.objects.select_by_class(reflection.klass).select do |object|
                object.send(reflection.inverse.uuid_getter) == self.uuid
              end
              PBXObjectList.new(reflection.klass, @project, scoped) do |object|
                object.send(reflection.inverse.uuid_setter, self.uuid)
              end
            end
          else
            attribute(reflection.name, :as => reflection.uuids_getter)
            define_method(reflection.name) do
              Association::HasMany.new(self, reflection, &block).get
            end
            define_method(reflection.plural_setter) do |list|
              Association::HasMany.new(self, reflection, &block).set(list)
            end
          end
        end

        def self.has_one(singular_attr_name, options = {})
          reflection = create_reflection(singular_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              # Loop over all objects of the class and find the one that includes
              # this object in the specified uuid list.
              @project.objects.select_by_class(reflection.klass).find do |object|
                object.send(reflection.inverse.uuids_getter).include?(self.uuid)
              end
            end
            define_method(reflection.singular_setter) do |object|
              # Remove this object from the uuid list of the target
              # that this object was associated to.
              if previous = send(reflection.name)
                previous.send(reflection.inverse.uuids_getter).delete(self.uuid)
              end
              # Now assign this object to the new object
              object.send(reflection.inverse.uuids_getter) << self.uuid if object
            end
          else
            attribute(reflection.uuid_attribute, :as => reflection.uuid_getter)
            define_method(reflection.name) do
              Association::HasOne.new(self, reflection).get
            end
            define_method(reflection.singular_setter) do |new_object|
              Association::HasOne.new(self, reflection).set(new_object)
            end
          end
        end
      end

    end
  end
end
